if (!window.furueru) window.furueru = {  };

window.furueru.dispatcher = function(guard, func) {
    window.furueru.dispatcher.path_func = window.furueru.dispatcher.path_func || []
    if (func) {
        window.furueru.dispatcher.path_func.push([guard, func]);
        return;
    }
    window.furueru.dispatcher.path_func.forEach(function(pair) {
        var guard = pair[0];
        var func = pair[1];

        if (
            guard == true
                || (typeof guard == "string" && location.pathname == guard)
                || (guard.test && guard.test(location.pathname))
        ) func();
    });
};

window.furueru.index = {
    getImage: function(width, delay){
	$.post('furueru', 
	       {'width': width, 'delay': delay},
	       function(data){
		   $('img.result')
		       .attr('src', data.image);
		   $('.result').show('slow');
		   $('#decide').val($('img.result').attr('src'));
	       });
    }
};

window.furueru.dispatcher('/', function(){
    $('input[type=radio]').attr('checked', false);
    $('#purupuru').click(function(){
	window.furueru.index.getImage(1, 4);
    });
    $('#yurayura').click(function(){
	window.furueru.index.getImage(2, 6);
    });
    $('#guragura').click(function(){
	window.furueru.index.getImage(4, 4);
    });
});

$(function() {
    window.furueru.dispatcher();
});
