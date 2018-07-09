// $(function(){
// 	$("#button1").click(function(){
// 		$.ajax({
// 			url: '/gumbek',
// 			type: 'POST',
// 			dataType: "json",
// 			success: function(response){
// 				console.log(response.jebacina);
// 				g.refresh(response.jebacina);
// 			},
// 			error: function(error){
// 				console.log(error);
// 			}
// 		});
// 	});
// });

var temp = new JustGage({
	id: "gauge_temp",
	value: 67,
	min: 0,
	max: 100,
	title: "Temperature"
});

var pres = new JustGage({
	id: "gauge_pres",
	value: 67,
	min: 0,
	max: 1100,
	title: "Pressure"
});

var hum = new JustGage({
	id: "gauge_hum",
	value: 67,
	min: 0,
	max: 100,
	title: "Humidity"
});

(function worker() {
  $.ajax({
    url: '/gumbek',
    type: 'POST',
	dataType: "json",
    success: function(data) {
      	console.log(data.temp);
      	console.log(data.pres);
      	console.log(data.hum);
		temp.refresh(data.temp);
		pres.refresh(data.pres);
		hum.refresh(data.hum);
    },
    error: function(error){
		console.log(error);
	},
    complete: function() {
      console.log("Tu sam")
      setTimeout(worker, 5000);
    }
  });
})();