#!/usr/bin/env python3
# -*- coding: utf-8 -*-

def le_compte_est_bon(nombres: list, only_ints: bool = True, parentheses: bool = False, goal = None):
    operateurs = ['+' for i in range(len(nombres)-1)]
    results = []
    for i in range(0, 4**(len(nombres)-1)):
        for op_index in range(0, len(operateurs)):
            if operateurs[op_index] == '+':
                operateurs[op_index] = '-'
                break
            if operateurs[op_index] == '-':
                operateurs[op_index] = '*'
                break
            if operateurs[op_index] == '*':
                operateurs[op_index] = '/'
                break
            if operateurs[op_index] == '/':
                operateurs[op_index] = '+'
        operation = str(nombres[0])
        for i in range(0, len(operateurs)):
            operation += operateurs[i] + str(nombres[i+1])
        result = eval(operation)
        if only_ints:
            if (float(int(result)) != result) or (result < 0):
                continue
            else:
                result = int(result)
        if goal == result:
            return operation
        results.append((operation, result))
        if parentheses:
            for i in range(0, len(operateurs)-1):
                for j in range(i+1, len(operateurs)):
                    if i == 0:
                        operation = '(' + str(nombres[0])
                    else:
                        operation = str(nombres[0])
                    for k in range(0, len(operateurs)):
                         operation += operateurs[k]
                         if k == i-1:
                             operation += '('
                         operation += str(nombres[k+1])
                         if k == j-1:
                             operation += ')'
                    try:
                        result = eval(operation)
                    except ZeroDivisionError:
                        continue
                    if only_ints:
                        if (float(int(result)) != result) or (result < 0):
                            continue
                        else:
                            result = int(result)
                    if goal == result:
                        return operation
                    results.append((operation, result))
    if goal == None:
        return results
    else:
        return "PAS TROUVÉ"