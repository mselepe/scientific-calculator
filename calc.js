// Cnvert the equation so that it's solvable
function convertInput (equation) {
    var convertedEq = new Array();
    
    if (equation.length > 0) {
        var valuesInEquation = equation.split(/[-+/×]/);
        var convertedValue = new Array();
        var symbols = new Array();

        var valuesInBrackets = new Array();
        for (var i=0; i<valuesInEquation.length; i++) {
            var currentChar = valuesInEquation[i]; 
            if (currentChar.startsWith("(")) {

                // while (!currentChar.endsWith(")")) {
                valuesInBrackets.push(currentChar);
                // }
    
            }

        }

        for (var i=0; i<valuesInEquation.length; i++) {
            var currentChar = valuesInEquation[i];            
        

            if (!isNaN(currentChar)){ //convert digits to number
                convertedValue.push(Number(currentChar)); 
                // console.log(typeof currentChar);
            } else { 
                currentChar = scientificButtonConversion(currentChar);
                convertedValue.push(currentChar); 
            }
        }    

        

        // var symbolsInEquation;
        return valuesInBrackets;
    } else {
        return "";
    }
}


function scientificButtonConversion(currentChar) {
    if (currentChar === "π") {currentChar = Math.PI;
    } else if (currentChar === "e") {
        currentChar = Math.E;

    } else if (currentChar.startsWith("EE")) {
        var power = Number(currentChar.slice(2));
        currentChar = Math.pow(10, power);

    } else if (currentChar.startsWith("∛")) {
        var base = Number(currentChar.slice(1));
        currentChar = Math.cbrt(base);

    } else if (currentChar.startsWith("√")) {
        var base = Number(currentChar.slice(1));
        currentChar = Math.sqrt(base);

    } else if (currentChar.startsWith("±")){
        var base = Number(currentChar.slice(1));
        currentChar = base * -1;

    } else if (currentChar.endsWith("²")) {
        var base = Number(currentChar.slice(0, -1));
        currentChar = Math.pow(base, 2);

    } else if (currentChar.endsWith("³")) {
        var base = Number(currentChar.slice(0, -1));
        currentChar = Math.pow(base, 3);

    } else if (currentChar.startsWith("e^")) {
        var indexOfPowerSymbol = currentChar.indexOf("^");
        var power = Number(currentChar.slice(indexOfPowerSymbol+1));
        currentChar = Math.exp(power);
        
    } else if (currentChar.includes("^")) {
        var indexOfPowerSymbol = currentChar.indexOf("^");
        var base = Number(currentChar.slice(0, indexOfPowerSymbol));
        var power = Number(currentChar.slice(indexOfPowerSymbol+1));
        currentChar = Math.pow(base, power);
    
    } else if (currentChar.endsWith("!")) {
        var base = Number(currentChar.slice(0, -1));
        currentChar = factorial(base);
    
    } else if (currentChar.endsWith("%")) {
        var base = Number(currentChar.slice(0, -1));
        currentChar = base/100;
    
    } else if (currentChar.startsWith("abs(")) {
        var base = Number(currentChar.slice(0, -1));
        currentChar = Math.abs(base);
    
    } else if (currentChar.startsWith("ln(")) {
        var base = Number(currentChar.slice(0, -1));
        currentChar = Math.abs(base);
    
    } else if (currentChar.startsWith("log(")) {
        var base = Number(currentChar.slice(0, -1));
        currentChar = Math.abs(base);
    
    } else if (currentChar.startsWith("sinh(")) {
        var base = Number(currentChar.slice(0, -1));
        currentChar = Math.abs(base);
    
    } else if (currentChar.startsWith("cosh(")) {
        var param = currentChar.slice(2);
        currentChar = Math.pow(10, param);
    
        equationArray.splice(param, 1);
    } else if ( currentChar.startsWith("tanh(")) {
        var param = currentChar.slice(2);
        currentChar = Math.pow(10, param);
    
        equationArray.splice(param, 1);
    } else if (currentChar.startsWith("sin(")) {
        var param = currentChar.slice(2);
        currentChar = Math.pow(10, param);
    
        equationArray.splice(param, 1);
    } else if (currentChar.startsWith("cos(")) {
        var param = currentChar.slice(2);
        currentChar = Math.pow(10, param);
    
        equationArray.splice(param, 1);
    } else if (currentChar.startsWith("tan(")) {
        var param = currentChar.slice(2);
        currentChar = Math.pow(10, param);
        equationArray.splice(param, 1);
    }

        // console.log(typeof currentChar);
    return currentChar;
    
}


function handleBrackets(equationInBrackets) {
    if (equation.length === 0 || equation.length === 1 ) {
        return equation;
    } 
    // else if () {}
    //  else {
    //     return 
    // }
}


function factorial(num) {
    let result = 1;
    for (let i = num; i>0; i--) {
        result*=i;
    }
    return result;
}

function displayValue(value) {
    var display = document.getElementById("equation");
    display.value += value; 
}

function displayAnswer(answer) {
    document.getElementById("equation").value = answer;
}


var equation;
document.getElementById("equalSign").onclick = function () {
    var equation = document.getElementById("equation").value;
    var convertedEquation = convertInput(equation);
    
    displayAnswer(convertedEquation);
    console.log(convertedEquation);
}

document.getElementById("allClear").onclick = function () {
    document.getElementById("equation").value = "";    
}