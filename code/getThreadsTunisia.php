<?php

  $mysql = mysql_connect("deebee.yourdefaulthomepage.com","gonkclub","cakebread") or die(mysql_error());
	
	mysql_select_db("140kit_scratch_1",$mysql) or die(mysql_error());
	$table="tweets";
	$maxID=185000;	
	
	// max thread ID - to be calculated
	$query1 = "select MAX(thread_id) from `$table`";
	
	$r1 = mysql_query($query1,$mysql) or die(mysql_error());
	$r1 = mysql_fetch_array($r1);
	$maxThreadID = $r1[0];
	
	
	for ($i=0;$i<50000;$i++){
	
		// get entries whose thread ID is zero
		$randNum = rand(0,$maxID);
		$query = "select * from `$table` where `thread_id`=0 and id>".$randNum." limit 1";	
		$result1 = mysql_query($query,$mysql) or die(mysql_error());
		
		if (mysql_num_rows($result1)>0) {
			
			while ($curTweet = mysql_fetch_array($result1)) {
			
				// get current id row from database
				$curThreadID = $maxThreadID++;
				$id = $curTweet[id];
				$curWords = explode(",",$curTweet[words]);
				$curSize = sizeof($curWords);	// size of current tweet
			//	echo "words: $curWords --- size: $curSize<br/>";
				echo "$curTweet[text]<br/>";
				
				// only if a tweet constitutes of at least three words
				if ($curSize>5) {
					
					$loops=0;
					$continue=true;
					while ($continue){
				
						// update thread_id
						$query = "UPDATE `$table` SET thread_id='{$curThreadID}' WHERE id='{$id}'";
						$result2 = mysql_query($query,$mysql) or die(mysql_error()); 
				
						$randPos = rand(1,$curSize-3);
						$curWordsStr = $curWords[$randPos].",".$curWords[$randPos+1].",".$curWords[$randPos+2].",".$curWords[$randPos+3];
						
						// look for other tweets that might be similar to this one
						$query1 = "SELECT * FROM `$table` WHERE `words` like '%".$curWordsStr."%' and `id`!='".$id."'";			
						$result2 = mysql_query($query1,$mysql) or die(mysql_error()); 
					
						$numFound=0;
						$total = mysql_num_rows($result2);
						if ($total > 0) {
								
							//echo "<br><br>$curTweet[text]<br><br>";				
							while ($row = mysql_fetch_array($result2)) {
					
								$threshold = $curSize * 8 / 10;			// set threshold of 0.8 for similarity
								$iterID = $row[id];
								$iterWords = explode(",",$row[words]);
								$compWords = array_intersect($curWords,$iterWords);		// get intersection of words
								$arrSize = 	sizeof($compWords);
								$shared_words = implode(",", $compWords);
									
								// they are part of the same thread
								if ($arrSize >= $threshold) {
											
									$num = (int) $row[thread_id];
									if ( $num == 0 ) {	
										// update current entry's thread_id and shared_words array (link it to a certain thread)
										$query = "UPDATE `$table` SET thread_id='{$curThreadID}', shared_words='{$shared_words}' WHERE id='{$iterID}'";
										$result = mysql_query($query,$mysql) or die(mysql_error()); 
										$numFound++;
										echo "$row[text]<br/>";
									}	
								}
								
							}//while
						
						}//if ($total > 0)
						
						$loops++;
						if (($numFound>0) || ($loops>4)){
							$continue=false;
						}		
					}
					
				}// if ($curSize > 4)
				else {
					// don't want to deal with this tweet ---> too short	
					$query = "UPDATE `$table` SET thread_id='-1' WHERE id='{$id}'";
					$result = mysql_query($query,$mysql) or die(mysql_error());
				}
				
				echo "found: $numFound<br/>";
			}
		}
	}

?>