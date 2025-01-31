// function getInput(value) {
//     const displayScreen = document.getElementById("input-getValue");
//     displayScreen.value += value;
// }

// function () {}

function convertInput (equation) {
    var convertedEq = new Array();
    
    // Convert the numbers
    if (equation.length > 0) {
        var valuesInEquation = equation.split(/[-+/×]/);
        var convertedValue = new Array();
        var symbols = new Array();

        for (var i=0; i<valuesInEquation.length; i++) {
            var currentChar = valuesInEquation[i];            
        
            if (!isNaN(currentChar)){ //convert digits to number
                convertedValue.push(Number(currentChar)); 
                console.log(typeof currentChar);
            } else { 
                convertedValue.push(currentChar); 
            }
        }    

        var symbolsInEquation
        return convertedValue;
    } else {
        return "";
    }
}

function squareNumber(value) {
    Math.pow(value, 2)
}


function memoryWork(equationArray) {
    for (var i=0; i<equationArray.length; i++) {
        var currentChar = equationArray[i];

        switch(currentChar) {
            case "π":
                currentChar = Math.PI;
                break;

            case "e":
                currentChar = Math.E;
                break;

            case currentChar.startsWith("EE"):
                var power = Number(currentChar.slice(2));
                currentChar = Math.pow(10, power);
                break;
                
            case currentChar.startsWith("∛"):
                var base = Number(currentChar.slice(1));
                currentChar = Math.cbrt(base);
                break;

            case currentChar.startsWith("√"):
                var base = Number(currentChar.slice(1));
                currentChar = Math.sqrt(base);
                break;

            case currentChar.startsWith("±"):
                var base = Number(currentChar.slice(1));
                currentChar = base * -1;
                break;

            case currentChar.endsWith("²"):
                var base = Number(currentChar.slice(0, -1));
                currentChar = Math.pow(base, 2);
                break;

            case currentChar.endsWith("³"):
                var base = Number(currentChar.slice(0, -1));
                currentChar = Math.pow(base, 3);
                break;

            case currentChar.endsWith("!"):
                var base = Number(currentChar.slice(0, -1));
                currentChar = Math.abs(base);
                break;
            
            case currentChar.endsWith("%"):
                var base = Number(currentChar.slice(0, -1));
                currentChar = base/100;
                break;
            
            case currentChar.startsWith("ln("):
                var base = Number(currentChar.slice(0, -1));
                currentChar = Math.abs(base);
                break;
              
            case currentChar.startsWith("log("):
                var base = Number(currentChar.slice(0, -1));
                currentChar = Math.abs(base);
                break;
        
            case currentChar.startsWith("sinh("):
                var base = Number(currentChar.slice(0, -1));
                currentChar = Math.abs(base);
                break;    

            case currentChar.startsWith("cosh("):
                var param = currentChar.slice(2);
                currentChar = Math.pow(10, param);
                equationArray.splice(param, 1);
                break;

            case currentChar.startsWith("tanh("):
                var param = currentChar.slice(2);
                currentChar = Math.pow(10, param);
                equationArray.splice(param, 1);
                break;

            case currentChar.startsWith("sin("):
                var param = currentChar.slice(2);
                currentChar = Math.pow(10, param);
                equationArray.splice(param, 1);
                break;

            case currentChar.startsWith("cos("):
                var param = currentChar.slice(2);
                currentChar = Math.pow(10, param);
                equationArray.splice(param, 1);
                break;

            case currentChar.startsWith("tan("):
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

function factorial(num) {
    let result = 1;
    for (let i = num; 0<i <= num; i--) {
        result*=i;
    }
    return result;
}



var equation;

document.getElementById("equalSign").onclick = function () {
    // var box = document.getElementById("equation");
    equation = document.getElementById("equation").value;
    
    // var convertedEquation = convertInput(equation);
    // for (var i=0; i<convertedEquation.length; i++) {
    //     var t = convertedEquation[i];
    //     if (!isNaN(t)) {

    //     }
    // }
    
    displayAnswer(factorial(3));
    console.log(factorial(3));
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