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
    hideResult: function(){
	$('img.result').hide('slow');
	$('#update-image').attr('disabled', true);
	$('input[type=radio]').attr('disabled', true);
    },
    showResult: function(){
	$('img.result').show('slow');
	$('p.result').show('slow');
	$('form.result').fadeIn('slow');
	$('#update-image').attr('disabled', false);
	$('input[type=radio]').attr('disabled', false);
    },
    getImage: function(width, delay){
	var self = this;
	self.hideResult();
	$.post('furueru', 
	       {'width': width, 'delay': delay, 'token': $('#image-token').val()},
	       function(data){
		   $('img.result').attr('src', data.image);
		   $('#update-image-path').val($('img.result').attr('src'));
		   self.showResult();
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

$(document).ready(function(){
    $('#adsense').jrumble({
	rangeX: 3,
	rangeY: 0,
	rangeRot: 0,
	rumbleSpeed: 30,
	rumbleEvent: 'constant'
    });
});
