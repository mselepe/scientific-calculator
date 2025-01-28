// function getInput(value) {
//     const displayScreen = document.getElementById("input-getValue");
//     displayScreen.value += value;
// }

// function () {}

// function convertInput (equation) {
//     var equationList = equation.split();

//     for (var i=0; i<equation.length; i++) {
//         var currentChar = equation.charAt(i);
//         var previousChar = equation.charAt(i-1);

//         if (currentChar =="(") {
//             if (previousChar.match(/| /)) {
                
//             }
//         }
//     }
// }

// function solve(equationArray) {}
// solve();

var equation;

document.getElementById("equalSign").onclick = function () {
    equation = document.getElementById("equation").value;

    var equationArray = equation.split(/| /);


    // for (var i=0; i<equation.length; i++) {
    //     var currentChar = equationArray.charAt(i);
    //     var previousChar = equationArray.charAt(i-1);
        
    //     if (!isNaN(currentChar)) { //convert digits to number
    //         currentChar = Number(currentChar);
    //     }
    // }
    
    console.log(typeof equationArray);
    // if (currentChar == "(") {
        
    // }
    

}