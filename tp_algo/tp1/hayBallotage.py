def sumaDeVotos(escrutinio:list)->int:
    res:int = 0
    for i in range(0,len(escrutinio)-1,1):
        res = res + escrutinio[i]
    return res

def maximo(escrutinio:list)->int:
    res:int = 0
    for i in range(0,len(escrutinio)-1,1):
        if (escrutinio[i] > res):
            res = escrutinio[i]
    return res

def segundo(escrutinio:list)->int:
    primero:int = 0
    segundo:int = 0
    for i in range(0,len(escrutinio)-1,1):
        if (escrutinio[i] > primero):
            segundo = primero
            primero = escrutinio[i]
        elif (escrutinio[i] > segundo):
            segundo = escrutinio[i]
    return segundo

def nadieSupera40Porciento(escrutinio:list)->bool:
    res = False
    if ((maximo(escrutinio) / sumaDeVotos(escrutinio)) < 0.40):
        res = True
    return res

def alguienSupera40Porciento(escrutinio:list)->bool:
    res:bool = True
    if ((maximo(escrutinio) / sumaDeVotos(escrutinio)) > 0.45):
        res = False
    elif((maximo(escrutinio) - segundo(escrutinio)) / sumaDeVotos(escrutinio) >= 0.10):
        res = False
    return res

def hayBallotage(escrutinio:list)->bool:
    res = False
    if (nadieSupera40Porciento(escrutinio) or alguienSupera40Porciento(escrutinio)):
        res = True
    return res

print(hayBallotage((10,5,3,2,0)))
print(hayBallotage((8,5,3,2,2)))
print(hayBallotage((8,7,3,2,0)))
print(hayBallotage((7,6,4,2,1)))