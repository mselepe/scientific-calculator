// function getInput(value) {
//     const displayScreen = document.getElementById("input-getValue");
//     displayScreen.value += value;
// }

// function () {}

function convertInput (equation) {
    var convertedEq = new Array();
    
    // Convert the numbers
    if (equation.length > 0) {
        var valuesInEquation = equation.split(/[-+/x]/);
        var convertedValue = new Array();
        var symbols = new Array();

        for (var i=0; i<valuesInEquation.length; i++) {
            var currentChar = valuesInEquation[i];
            var sqrChar = String.fromCharCode("&sup");
            
            if (currentChar[1] === "2"|| currentChar.endsWith("&sup3;")) {
                convertedValue.push(currentChar)
            }
            
            // if (!isNaN(currentChar) || currentChar==="e" || currentChar.startsWith("EE") || currentChar==="in" || currentChar.startsWith("log") || currentChar.startsWith("sin") || currentChar.startsWith("cos") || currentChar.startsWith("tan") || currentChar.startsWith("m") || currentChar.startsWith("π")) { //convert digits to number
            //     if (!isNaN(currentChar)){ 
            //         convertedValue.push(Number(currentChar)); 
            //         console.log(typeof currentChar);
            //     } else { 
            //         switch(currentChar) {
            //             case "π":
            //                 convertedValue.push(Math.PI);
            //                 break;
            //             case "e":
            //                 convertedValue.push(Math.E);
            //                 break;
            //             case "EE":
            //                 // convertedValue.push(Math.pow(10));
            //                 break;
            //             case "sin":
            //                 convertedValue.push(Math.E);
            //                 break;
            //             case "cos":
            //                 convertedValue.push(Math.E);
            //                 break;
            //             case "tan":
            //                 convertedValue.push(Math.E);
            //                 break;

            //             default:
            //               // code block
            //           }
            //           convertedValue.push(currentChar); 

            //     }
            // } 
        }    

        var symbolsInEquation
        return convertedValue;
    } else {
        return "";
    }
}


function memoryWork(equationArray) {
    for (var i=0; i<equationArray.length; i++) {
        var currentChar = equationArray[i];

        switch(currentChar) {
            case "π":
                // convertedValue.push(Math.PI);
                currentChar = Math.PI;
                break;
            case "e":
                // convertedValue.push(Math.E);
                currentChar = Math.E;
                break;
            case currentChar.startsWith("EE"):
                // convertedValue.push(Math.pow(10));
                var power = currentChar.slice(2);
                currentChar = Math.pow(10, power);
                equationArray.splice(power, 1);
                break;
            case "sinh":
                var param = currentChar.slice(2);
                currentChar = Math.pow(10, param);
                equationArray.splice(param, 1);

                break;
            case "cosh":
                var param = currentChar.slice(2);
                currentChar = Math.pow(10, param);
                equationArray.splice(param, 1);

                break;
            case "tanh":
                var param = currentChar.slice(2);
                currentChar = Math.pow(10, param);
                equationArray.splice(param, 1);
                break;

            default:
                // code block
            }

        convertedValue.push(currentChar); 
    }
    console.log(typeof currentChar);
    
}

// function solve(equationArray) {}
// solve();



var equation;

document.getElementById("equalSign").onclick = function () {
    // var box = document.getElementById("equation");
    equation = document.getElementById("equation").value;
    
    var convertedEquation = convertInput(equation);
    // for (var i=0; i<convertedEquation.length; i++) {
    //     var t = convertedEquation[i];
    //     if (!isNaN(t)) {

    //     }
    // }
    
    displayAnswer(convertedEquation);
    console.log(convertedEquation);
}

function displayAnswer(answer) {
    document.getElementById("equation").value = answer;
}

function displayValue(value) {
    var display = document.getElementById("equation");
    display.value += value; 
}

document.getElementById("allClear").onclick = function () {
    document.getElementById("equation").value = "";
    
}

// document.getElementById("mc").onclick = function () {
//     document.getElementById("equation").value = "mc";
    
// }