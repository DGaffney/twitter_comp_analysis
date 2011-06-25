var labelType, useGradients, nativeTextSupport, animate;

var st;

(function() {
  var ua = navigator.userAgent,
      iStuff = ua.match(/iPhone/i) || ua.match(/iPad/i),
      typeOfCanvas = typeof HTMLCanvasElement,
      nativeCanvasSupport = (typeOfCanvas == 'object' || typeOfCanvas == 'function'),
      textSupport = nativeCanvasSupport 
        && (typeof document.createElement('canvas').getContext('2d').fillText == 'function');
  //I'm setting this based on the fact that ExCanvas provides text support for IE
  //and that as of today iPhone/iPad current text support is lame
  labelType = (!nativeCanvasSupport || (textSupport && !iStuff))? 'Native' : 'HTML';
  nativeTextSupport = labelType == 'Native';
  useGradients = nativeCanvasSupport;
  animate = !(iStuff || !nativeCanvasSupport);
})();

var Log = {
  elem: false,
  write: function(text){
    if (!this.elem) 
      this.elem = document.getElementById('log');
    this.elem.innerHTML = text;
    // this.elem.style.left = (500 - this.elem.offsetWidth / 2) + 'px';
  }
};


function init(json){
    //init Spacetree
    //Create a new ST instance
    // var
	  var actor_colors = {"1":"#FEFF80",
	                      "2":"#CCFE80",
	                      "3":"#80FE80",
	                      "4":"#80FFFE",
	                      "5":"#809FFE",
	                      "6":"#AA80FE",
	                      "7":"#D580FE",
	                      "8":"#FE80DF",
	                      "9":"#FE8080",
	                      "10":"#FEB380",
	                      "11":"#FECC80",
	                      "14":"#FEE680",
	                      "uncategorized":"#ccc"}
	  var actor_types = {1:"MSM",
	                      2:"Web News Org",
	                      3:"Non Media Org",
	                      4:"Journalist",
	                      5:"Digerati",
	                      6:"Political Actor",
	                      7:"Celeb",
	                      8:"Blogger",
	                      9:"Activist",
	                      10:"Other",
	                      11:"Researcher",
	                      14:"Bot",
	                      "Uncategorized Actor":"#ccc"}
    st = new $jit.ST({
        //id of viz container element
        injectInto: 'infovis',
        //set duration for the animation
        duration: 500,
        //set animation transition type
        transition: $jit.Trans.Quart.easeInOut,
        //set distance between node and its children
        levelDistance: 50,
        levelsToShow: 20,
        constrained: false,
        //enable panning
        Navigation: {
          enable:true,
          panning:true
        },
        //set node and edge styles
        //set overridable=true for styling individual
        //nodes or edges
        Node: {
            height: 12,
            width: 80,
            type: 'none',
            color: '#999',
            overridable: true
        },
        
        Edge: {
            type: 'bezier',
            // color:"#ecd0ac",
            color:"#666",
            overridable: true
        },
        
        Label: {  
            type: 'HTML',  
            // size: 10,  
            // color: '#23A4FF'  
          },
        
        onBeforeCompute: function(node){
            Log.write("loading " + node.name);
        },
        
        onAfterCompute: function(){
            Log.write("done");
        },
        
        //This method is called on DOM label creation.
        //Use this method to add event handlers and styles to
        //your node.
        onCreateLabel: function(label, node){
            label.id = node.id;            
            label.innerHTML = node.name;
            label.onclick = function(){
              // if(normal.checked) {
            	  st.onClick(node.id);
              // } else {
              //                 st.setRoot(node.id, 'animate');
              // }
            };
            //set label styles
            var style = label.style;
            style.width = 80 + 'px';
            style.height = 17 + 'px';            
            style.cursor = 'pointer';
            // style.color = actor_colors["uncategorized"];//'#23A4FF';
            style.fontSize = '10px';
            style.textAlign= 'left';
            // style.paddingTop = '3px';
            // style.paddingBottom = '2px';
            style.paddingLeft = '3px';
            var actor_type = actor_types[actor_index[node.name.toLowerCase()]] || "uncategorized";
						
            style.color = actor_colors[actor_index[node.name.toLowerCase()]] || "#ccc";
            if (actor_type != "uncategorized")
              style.fontWeight = "bold"
        },
        
        //This method is called right before plotting
        //a node. It's useful for changing an individual node
        //style properties before plotting it.
        //The data properties prefixed with a dollar
        //sign will override the global node style properties.
        onBeforePlotNode: function(node){
            //add some color to the nodes in the path between the
            //root node and the selected node.
            
            var label = document.getElementById(node.id);
            if (label != null) {
              if (node.selected) {
                label.style.fontWeight = "bold";
              } else {
                var actor_type = actor_index[node.name.toLowerCase()] || "uncategorized";
                if (actor_type == "uncategorized")
                  label.style.fontWeight = "normal";
              }
            }
                // div.style.color = "#23A4FF"
                // if (node.anySubnode())
                  // div.style.fontWeight = "bold"
            
            // if (node.selected) {
            //   if (div != null) {
            //     div.style.fontWeight = "bold";
            //     // div.style.color = "#13E4FF"
            //   }
            // } else {
            //   if (div != null) {
            //     div.style.fontWeight = "normal";
            //     // div.style.color = "#23A4FF"
            //     // if (node.anySubnode())
            //       // div.style.fontWeight = "bold"
            //   }
            //   delete node.data.$color;
            //   //if the node belongs to the last plotted level
            //   if(!node.anySubnode("exist")) {
            //     //count children number
            //     var count = 0;
            //     node.eachSubnode(function(n) { count++; });
            //     //assign a node color based on
            //     //how many children it has
            //     node.data.$color = ['#aaa', '#baa', '#caa', '#daa', '#eaa', '#faa'][count];        
            //   }
            // }
            
            // if (div != null) {
            //   var actor_type = actor_index[node.name.toLowerCase()] || "uncategorized";
            //   div.style.color = actor_colors[actor_type];
            //   if (actor_type != "uncategorized")
            //     div.style.fontWeight = "bold"
            // }
        },
        
        //This method is called right before plotting
        //an edge. It's useful for changing an individual edge
        //style properties before plotting it.
        //Edge data proprties prefixed with a dollar sign will
        //override the Edge global style properties.
        onBeforePlotLine: function(adj){
            if (adj.nodeFrom.selected && adj.nodeTo.selected) {
                adj.data.$color = "#eed";
                adj.data.$lineWidth = 3;
            }
            else {
                delete adj.data.$color;
                delete adj.data.$lineWidth;
            }
        }
    });
    //load json data
    st.loadJSON(json);
    //compute node positions and layout
    st.compute();
    //optional: make a translation of the tree
    st.geom.translate(new $jit.Complex(-200, 0), "current");
    //emulate a click on the root node.
    st.onClick(st.root);
    //end
    //Add event handlers to switch spacetree orientation.
    // var top = $jit.id('r-top'), 
    //     left = $jit.id('r-left'), 
    //     bottom = $jit.id('r-bottom'), 
    //     right = $jit.id('r-right'),
    //     normal = $jit.id('s-normal');
    //     
    // 
    // function changeHandler() {
    //     if(this.checked) {
    //         top.disabled = bottom.disabled = right.disabled = left.disabled = true;
    //         st.switchPosition(this.value, "animate", {
    //             onComplete: function(){
    //                 top.disabled = bottom.disabled = right.disabled = left.disabled = false;
    //             }
    //         });
    //     }
    // };
    
    // top.onchange = left.onchange = bottom.onchange = right.onchange = changeHandler;
    //end

}
