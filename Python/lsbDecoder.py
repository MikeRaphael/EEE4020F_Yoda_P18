from PIL import Image
import numpy as np
import sys
import timeit
from timeit import default_timer as timer

def loadImage(ImageName):
    im = Image.open(ImageName) 
    pixels = list(im.getdata())
    width, height = im.size 
    pixels = [[pixel[0], pixel[1], pixel[2]] for pixel in pixels]
    return pixels

def decodeImage(pixels):
    decodedArr = pixels
    message = []
    letter = [] 
    colour = 0
    numPixel = 0
    bitCounter = 0
    for i in range(len(decodedArr)):
        if(colour == 3):
            colour = 0
            numPixel = numPixel +1
        x = (bin(pixels[numPixel][colour])[2:])[-1:]
        letter.append(x)
        colour = colour +1
        if(len(letter) == 8):
            if(letter == ['0','0','0','0','0','0','0','0']):
                break
            message.append(letter)
            letter = []
    return message

def string2bits(s):
    return [bin(ord(x))[2:].zfill(8) for x in s]

def bits2string(b):
    message = ""
    for byte in b:
        letter =""
        for bit in byte:
            letter = letter + bit
        message= message + (chr(int(letter, 2)))
    return message

def getInput():
    outputName =""
    if len(sys.argv) >1:	
        for argNum in range(len(sys.argv)):
            if (sys.argv[argNum].upper().find("-I")>-1):
                ImageName = sys.argv[argNum+1]
            elif(sys.argv[argNum].upper().find("-O") >-1):
                outputName =sys.argv[argNum+1]
            else:
                continue
    return ImageName,outputName

def main():
    start = timer()
    ImageName,outputName = getInput()
    pixels = loadImage(ImageName)
    starttime = timeit.default_timer()
    bitMessage = decodeImage(pixels)
    message = bits2string(bitMessage)
    end=timer()
    print(message)
    totaltime = timeit.default_timer() - starttime
    #totaltime = end-start
    print("Decoding took: " , 1000000*totaltime,"us")
    timeTaken()

def timeTaken():
    setup = '''
from PIL import Image
def loadImage(ImageName):
    im = Image.open(ImageName) 
    pixels = list(im.getdata())
    width, height = im.size 
    pixels = [[pixel[0], pixel[1], pixel[2]] for pixel in pixels]
    return pixels    
ImageName= "Encoded.png"
pixels = loadImage(ImageName)
    '''

    testcode = '''
def decodeImage(pixels):
    decodedArr = pixels
    message = []
    letter = [] 
    colour = 0
    numPixel = 0
    bitCounter = 0
    for i in range(len(decodedArr)):
        if(colour == 3):
            colour = 0
            numPixel = numPixel +1
        x = (bin(pixels[numPixel][colour])[2:])[-1:]
        letter.append(x)
        colour = colour +1
        if(len(letter) == 8):
            if(letter == ['0','0','0','0','0','0','0','0']):
                break
            message.append(letter)
            letter = []
    return message

def bits2string(b):
    message = ""
    for byte in b:
        letter =""
        for bit in byte:
            letter = letter + bit
        message= message + (chr(int(letter, 2)))
    return message

bitMessage = decodeImage(pixels)
message = bits2string(bitMessage)
    '''
    number = 10000
    print( "Using timeit method - iterate",number,"of times and repeat 3 times.\nTime taken is: ",1000000*min(timeit.repeat(  stmt= testcode,setup=setup,  number=number,repeat = 3))/number,"us")


main()
