// Convert the equation so that it's solvable
function convertInput (equation) {
    var valuesInEquation;
    var splitEquation = equation.split(/| /);
    var convertedValues = new Array();
    var symbolsInEquation = new Array();
    var symbols = new Array();
    
    var convertedEq = new Array();

    if (equation.includes("+") || equation.includes("×") || equation.includes("/") || equation.includes("-")) {
        valuesInEquation = equation.split(/[-+/×]/);
    } else {
        valuesInEquation = [equation];
    }
    
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
            var symbols = ["-", "+", "×", "/"];
            var currentChar = splitEquation[i];            
            
            if (symbols.includes(currentChar)) {
                symbolsInEquation.push(currentChar);
            }
        }
        convertedEq.push(symbolsInEquation);
        return convertedEq;
    
    } else if (valuesInEquation.length === 1 || splitEquation.length === 1) {
        
        if (!isNaN(equation)){ //convert digits to number
            convertedEq.push(Number(equation)); 
        } else { 
            equation = scientificButtonConversion(equation);
            convertedEq.push(equation); 
        }   
        return convertedEq;
        
    } else {
        return "";
    }    
}    

// Extract the bracket equation from full equation
function solveBrackets(equation) {
    var valuesInBrackets = new Array();

    if (equation.length > 0) {
        if (equation.includes("(")) {
            valuesInBrackets = extractBrackets(equation);
            
            var convertedBracketEquation = convertInput(valuesInBrackets);
            var bracketSolution = solve(convertedBracketEquation);
            var start = equation.indexOf("(");
            var end = equation.indexOf(")")+1;
            
            var newEquation =  equation.substring(0, start) + bracketSolution + equation.substring((end));
            return newEquation;            

        } else {
            return equation;
        }
    }
}

// Extract the bracket equation from full equation
function extractBrackets(equation) {
    var valuesInBrackets;

    if (equation.length > 0) {
        
        if (equation.includes("(")) {
            var bracketOpenIndex;
            var bracketCloseIndex;
            for (var i=0; i<equation.length; i++) {
                bracketOpenIndex = equation.indexOf("(")+1;
                bracketCloseIndex = equation.indexOf(")")-1;
            }
            valuesInBrackets = equation.slice(bracketOpenIndex, bracketCloseIndex+1);             
        } 
        // console.log("valuesInBrackets");
        return valuesInBrackets;
    } else {
        return valuesInBrackets;
    }
    // }
}


// Convert and implement the scientific buttons on the calculator
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
        var base = checkBase(Number(currentChar.slice(1)));
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
        
        console.log(power);
        currentChar = Math.pow(base, power);
    
    } else if (currentChar.endsWith("!")) {
        var base = checkBase(Number(currentChar.slice(0, -1)));
        currentChar = factorial(base);
    
    } else if (currentChar.endsWith("%")) {
        var base = checkBase(Number(currentChar.slice(0, -1)));
        currentChar = base/100;
    
    } else if (currentChar.startsWith("abs")) {
        var base = checkBase(Number(currentChar.slice(3)));
        base = Number(base);
        currentChar = Math.abs(base);
    
    } else if (currentChar.startsWith("ln")) {
        var base = checkBase(Number(currentChar.slice(2)));
        base = Number(base);
        currentChar = Math.log(base);
    
    } else if (currentChar.startsWith("log10")) {
        var base = checkBase(Number(currentChar.slice(5)));
        base = Number(base);
        currentChar = Math.log10(base);
    
    } else if (currentChar.startsWith("sinh")) {
        var base = checkBase(Number(currentChar.slice(4)));
        base = Number(base);
        currentChar = Math.sinh(base);
    
    } else if (currentChar.startsWith("cosh")) {
        var base = checkBase(Number(currentChar.slice(4)));
        base = Number(base);
        currentChar = Math.cosh(base);
    
    } else if ( currentChar.startsWith("tanh")) {
        var base = checkBase(Number(currentChar.slice(4)));
        base = Number(base);
        currentChar = Math.tanh(base);
        
    } else if (currentChar.startsWith("sin")) {
        var base = checkBase(Number(currentChar.slice(3)));
        base = Number(base) * (Math.PI/180 );
        currentChar = Math.sin(base);
        
    } else if (currentChar.startsWith("cos")) {
        var base = checkBase(Number(currentChar.slice(3)));
        base = Number(base) * (Math.PI / 180 );
        currentChar = Math.cos(base);
        
    } else if (currentChar.startsWith("tan")) {
        var base = checkBase(Number(currentChar.slice(3)));
        base = Number(base) * (Math.PI / 180 );
        currentChar = Math.tan(base);
    }  

    return currentChar;        
}    

function solve(equationArray) {
    var valuesArray = equationArray[0];
    var answer;
    
    if (equationArray[1]) {
        var symbolArray = equationArray[1];
        symbolArray.forEach((stringSymbol, i)  => {
            if (stringSymbol === "/") {
                answer = valuesArray[i] / valuesArray[i+1];
                valuesArray[i] = answer;
                symbolArray.splice(i, 1);  
                valuesArray.splice(i+1, 1);  
            }
        })
        
        symbolArray.forEach((stringSymbol, i)  => {
            if (stringSymbol === "×") {
                answer = valuesArray[i] * valuesArray[i+1];
                valuesArray[i] = answer;
                symbolArray.splice(i, 1);  
                valuesArray.splice(i+1, 1);  
            }
        })
        
        for (var i=0; i<symbolArray.length; i++) {
            console.log(i);
            var symbol = symbolArray[i];
    
            if (symbol === "+") {
                answer = valuesArray[i] + valuesArray[i+1];
                valuesArray[i] = answer;
                symbolArray.splice(i, 1);  
                valuesArray.splice(i+1, 1);
            }
        }
    
        symbolArray.forEach((stringSymbol, i)  => {
            if (stringSymbol === "-") {
                answer = valuesArray[i] - valuesArray[i+1];
                valuesArray[i] = answer;
                symbolArray.splice(i, 1);  
                valuesArray.splice(i+1, 1);  
            }
        })

        return valuesArray[0];
    } else {
        return valuesArray;
    }
}

// Check whether the base is a number
function checkBase(base) {
    if (base && !["-", "+", "×", "/"].includes(base)) {
        return base;
    } else {
        return "NaN"
    }
}

// Get the factorial of a number
function factorial(num) {
    let result = 1;
    for (let i = num; i>0; i--) {
        result*=i;
    }
    return result;
}

// Display the entered value
function displayValue(value) {
    var display = document.getElementById("equation");
    display.value += value; 
}

// Display the answer
function displayAnswer(answer) {
    document.getElementById("equation").value = answer;
}

// Execute the calculator
var equation;
document.getElementById("equalSign").onclick = function () {
    var equation = document.getElementById("equation").value;
    var convertedEquation = solveBrackets(equation);
    var equationToSolve = convertInput(convertedEquation);
    // console.log(convertedEquation);
    var solution = solve(equationToSolve);
    
    displayAnswer(solution);
}

// Clear the  calculator text box
document.getElementById("allClear").onclick = function () {
    document.getElementById("equation").value = "";    
}