// Function to parse Scheme code

const nearley = require("nearley");
const grammar = require("./grammar.js");

const parser = new nearley.Parser(nearley.Grammar.fromCompiled(grammar));

function parseSchemeCode(code) {
    // parsing the scheme file
    try {
        parser.feed(code);
        return parser.results[0];
    } catch (error) {
        console.error('Error parsing Scheme code:', error);
        return null;
    }
}

// Function to detect potential reentrancy vulnerabilities
function detectReentrancyVulnerabilities(ast) {
    const reentrancyVulnerabilities = [];

    // Look for lambda expressions defining contract functions
    ast.body.forEach(node => {
        if (node.type === 'VariableDeclaration' && node.declarations[0].init.type === 'CallExpression') {
            const functionName = node.declarations[0].id.name;
            const functionBody = node.declarations[0].init.arguments[1].body;

            // Look for withdraw function
            if (functionName === 'DepositFunds') {
                const balances = findBalancesDeclaration(functionBody);

                // Look for withdraw case
                if (balances) {
                    const withdrawCases = findWithdrawCases(functionBody, balances);
                    if (withdrawCases.length > 0) {
                        reentrancyVulnerabilities.push({
                            function: functionName,
                            cases: withdrawCases
                        });
                    }
                }
            }
        }
    });

    return reentrancyVulnerabilities;
}

// Helper function to find balances declaration
function findBalancesDeclaration(node) {
    if (node.type === 'CallExpression' && node.callee.name === 'make-hash') {
        return node;
    } else if (node.body) {
        for (const childNode of node.body) {
            const result = findBalancesDeclaration(childNode);
            if (result) return result;
        }
    }
    return null;
}

// Helper function to find withdraw cases
function findWithdrawCases(node, balances) {
    const withdrawCases = [];

    if (node.type === 'CallExpression' && node.callee.name === 'case') {
        for (const branch of node.arguments.slice(1)) {
            if (branch.type === 'ArrayExpression' && branch.elements[0].value === 'withdraw') {
                const withdrawBody = branch.elements[1];
                const balance = findHashRefUsage(withdrawBody, balances);

                if (balance) {
                    const sent = findSentFunds(withdrawBody);
                    withdrawCases.push({
                        body: withdrawBody,
                        balance,
                        sent
                    });
                }
            }
        }
    } else if (node.body) {
        for (const childNode of node.body) {
            const result = findWithdrawCases(childNode, balances);
            withdrawCases.push(...result);
        }
    }

    return withdrawCases;
}

// Helper function to find hash-ref usage in withdraw function
function findHashRefUsage(node, balances) {
    if (node.type === 'CallExpression' && node.callee.name === 'hash-ref' && node.arguments[0].name === balances.declarations[0].id.name) {
        return node.arguments[1];
    } else if (node.body) {
        for (const childNode of node.body) {
            const result = findHashRefUsage(childNode, balances);
            if (result) return result;
        }
    }
    return null;
}

// Helper function to find sent variable usage in withdraw function
function findSentFunds(node) {
    if (node.type === 'CallExpression' && node.callee.name === 'set!') {
        if (node.arguments[0].name === 'sent') {
            return node.arguments[1];
        }
    } else if (node.body) {
        for (const childNode of node.body) {
            const result = findSentFunds(childNode);
            if (result) return result;
        }
    }
    return null;
}

/*
// Function to annotate or modify the code to mitigate vulnerabilities
function annotateVulnerabilities(ast, vulnerabilities) {
    // Annotate or modify the code to prevent reentrancy vulnerabilities
}
*/

// Main transpiler function
function transpileSchemeCode(code) {
    const ast = parseSchemeCode(code);
    const vulnerabilities = detectReentrancyVulnerabilities(ast);

    if (vulnerabilities.length > 0) {
        console.log("Potential reentrancy attack detected. Suggestions...");
        annotateVulnerabilities(ast, vulnerabilities);
        console.log("Vulnerabilities mitigated:");
        // console.log(vulnerabilities);
    }

    // Return the modified code
    return modified code
}
