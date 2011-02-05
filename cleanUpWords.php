<?php

    $mysql = mysql_connect("deebee.yourdefaulthomepage.com","gonkclub","cakebread") or die(mysql_error());
	  $story = 'tweets';
	
		mysql_select_db("140kit_scratch_2",$mysql) or die(mysql_error());
		$table="tweets";
		$maxID=185000;
  // } else {
  //  // sidibouzid
  //  echo "tunisia<br/><br/>";
  //  
  //  mysql_select_db("140kit_scratch_1",$mysql) or die(mysql_error());
  //  $table="tweets";
  //  $maxID=167000;
  // }
	
	// get all entries
	$query = "select * from `$story` order by pubdate asc";	
	$result = mysql_query($query,$mysql) or die(mysql_error());
	
	while ($curTweet = mysql_fetch_array($result)) {
		
		// get current id row from database
		$id = $curTweet[id];
		$cT = strtolower(loseDots($curTweet[text]));
		$curWords = explode(" ",$cT);	// array of words that make up current tweet
		$words = '';
		
		if (sizeof($curWords) > 0) {
			
			foreach($curWords as $word){
				$words.=$word.',';
			}
		}
	
		echo $words."</br>";
	
		// insert into database
		if ($words!=''){
			
			$query1 = "UPDATE `$story` SET words='{$words}' WHERE id='{$id}'";
			//echo $query1."</br>";
			$result1 = mysql_query($query1,$mysql) or die(mysql_error()); 
			
		}
	}

	function loseDots($str){
		
		$str = str_replace(",","",$str);
		$str = str_replace(".","",$str);
		$str = str_replace("?","",$str);
		$str = str_replace("!","",$str);
		$str = str_replace("’","",$str);
		$str = str_replace(":","",$str);
		$str = str_replace("'","",$str);
	//	$str = str_replace("/"," ",$str);
		$str = str_replace("\"","",$str);
	//	$str = str_replace("-"," ",$str);
		$str = str_replace("(","",$str);
		$str = str_replace(")","",$str);
		
		return $str;
	}


?>