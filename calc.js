// Cnvert the equation so that it's solvable
function convertInput (equation) {
    var valuesInEquation = equation.split(/[-+/×]/);
    var splitEquation = equation.split(/| /);
    var convertedValues = new Array();
    var symbolsInEquation = new Array();
    var symbols = new Array();

    var convertedEq = new Array();
    
    if (valuesInEquation.length > 1) {
        // Convert the values and put them in an array
        for (var i=0; i<valuesInEquation.length; i++) {
            var currentChar = valuesInEquation[i];            
        
            if (!isNaN(currentChar)){ //convert digits to number
                convertedValues.push(Number(currentChar)); 
            } else { 
                currentChar = scientificButtonConversion(currentChar);
                convertedValues.push(currentChar); 
            }
        }   
        convertedEq.push(convertedValues); 
        
        // Put the symbols in an array
        for (var i=0; i<splitEquation.length; i++) {
            var currentChar = splitEquation[i];            
        
            if (currentChar in ["-", "+", "×", "/"]) {
                symbolsInEquation.push(currentChar);
            }
        }
        convertedEq.push(symbols);

    } else if (valuesInEquation.length === 1 || splitEquation.length === 1) {

        if (!isNaN(equation)){ //convert digits to number
            convertedEq.push(Number(equation)); 
        } else { 
            equation = scientificButtonConversion(equation);
            convertedEq.push(equation); 
        }   
        return convertedEq;
    }  

    else {
        return "";
    }    
}    


function handleBrackets(equation) {
    var valuesInBrackets = new Array();

    if (equation.length > 0) {

        if (equation.includes("(")) {
            var bracketOpenIndex;
            var bracketCloseIndex;
            for (var i=0; i<valuesInEquation.length; i++) {
                bracketOpenIndex = equation.indexOf("(");
                bracketCloseIndex = equation.indexOf(")");
            }
            valuesInBrackets = equation.slice(bracketOpenIndex, bracketCloseIndex+1);
        }
        
    } else {
        return equation;
    }

}


function scientificButtonConversion(currentChar) {
    if (currentChar === "π") {
        currentChar = Math.PI;

    } else if (currentChar === "e") {
        currentChar = Math.E;

    } else if (currentChar.startsWith("EE")) {
        var power = checkBase(Number(currentChar.slice(2)));
        currentChar = Math.pow(10, power);

    } else if (currentChar.startsWith("∛")) {
        var base = checkBase(Number(currentChar.slice(1)));
        currentChar = Math.cbrt(base);

    } else if (currentChar.startsWith("√")) {
        var base = checkBase(Number(currentChar.slice(2)));
        currentChar = Math.sqrt(base);

    } else if (currentChar.startsWith("±")){
        var base = Number(currentChar.slice(1));
        currentChar = base * -1;

    } else if (currentChar.endsWith("²")) {
        var base = checkBase(Number(currentChar.slice(0, -1)));
        currentChar = Math.pow(base, 2);

    } else if (currentChar.endsWith("³")) {
        var base = checkBase(Number(currentChar.slice(0, -1)));
        currentChar = Math.pow(base, 3);

    } else if (currentChar.startsWith("e^")) {
        var indexOfPowerSymbol = currentChar.indexOf("^");
        var power = checkBase(Number(currentChar.slice(indexOfPowerSymbol+1)));
        currentChar = Math.exp(power);
        
    } else if (currentChar.includes("^")) {
        var indexOfPowerSymbol = currentChar.indexOf("^");
        var base = checkBase(Number(currentChar.slice(0, indexOfPowerSymbol)));
        var power = checkBase(Number(currentChar.slice(indexOfPowerSymbol+1)));
        currentChar = Math.pow(base, power);
    
    } else if (currentChar.endsWith("!")) {
        var base = checkBase(Number(currentChar.slice(0, -1)));
        currentChar = factorial(base);
    
    } else if (currentChar.endsWith("%")) {
        var base = checkBase(Number(currentChar.slice(0, -1)));
        currentChar = base/100;
    
    } else if (currentChar.startsWith("abs(")) {
        var base = Number(currentChar.slice(4, -1));
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

function checkBase(base) {
    if (base && !(base in ["-", "+", "×", "/"])) {
        return base;
    } else {
        return "NaN"
    }
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