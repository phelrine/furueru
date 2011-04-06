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
	$('.result').hide('slow');
	$('input[type=radio]').attr('disabled', true);
	$('#download').attr('disabled', true);
    },
    showResult: function(){
	$('.result').show('slow');
	$('#download').attr('disabled', false);
	$('input[type=radio]').attr('disabled', false);
    },
    vibrateImage: function(width, delay){
	var self = this;
	self.hideResult();
	$.post('furueru', 
{ 'src': $('#preview-image').attr("src"),
	'width': width, 
	'delay': delay, 
	},
	       function(data){
		   $('img.result').attr('src', data.image);
		   $('#result-file').val(data.image);
		   self.showResult();
	    });
    },
};

window.furueru.dispatcher('/', function(){
	$('input[type=radio]').attr('checked', false);
    $('#purupuru').click(function(){
	window.furueru.index.vibrateImage(1, 4);
    });
    $('#yurayura').click(function(){
	window.furueru.index.vibrateImage(2, 6);
    });
    $('#guragura').click(function(){
	window.furueru.index.vibrateImage(4, 4);
    });
    $('#download').click(function(){
	    window.furueru.index.downloadImage();
	});
    $('#upload-form').ajaxForm({
	    success: function(data, res){
		$('#garally').hide();
		$('#step2').fadeIn('slow');
		$("#preview-image")
		    .attr('src', data.filename)
		    .fadeIn('slow');
		return false;
	    },
		dataType: "json"
		});
    });

$(function() {
	window.furueru.dispatcher();
});
