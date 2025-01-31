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
            
            if (!isNaN(currentChar) || currentChar==="e" || currentChar==="EE" || currentChar==="in" || currentChar.startsWith("log") || currentChar.startsWith("sin") || currentChar.startsWith("cos") || currentChar.startsWith("tan") || currentChar.startsWith("m") || currentChar.startsWith("π")) { //convert digits to number
                if (!isNaN(currentChar)){ 
                    convertedValue.push(Number(currentChar)); 
                } else { 
                    switch(currentChar) {
                        case "π":
                            convertedValue.push(Math.PI);
                            break;
                        case y:
                            convertedValue.push("e");
                            break;
                        default:
                          // code block
                      }

                    convertedValue.push(currentChar); 
                }
                console.log(typeof currentChar);
            } 
        }    

        var symbolsInEquation
        return convertedValue;
    } else {
        return "";
    }
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

document.getElementById("allClear").onclick = function () {
    document.getElementById("equation").value = "";
    
}

// document.getElementById("mc").onclick = function () {
//     document.getElementById("equation").value = "mc";
    
// }
function displayValue (value) {
    var display = document.getElementById("equation");
    display.value += value; 
}