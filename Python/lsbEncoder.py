from PIL import Image
import numpy as np
import sys
import io

def loadImage(ImageName):
    im = Image.open(ImageName) 
    pixels = list(im.getdata())
    width, height = im.size 
    pixels = [[pixel[0], pixel[1], pixel[2]] for pixel in pixels]
    return pixels,width, height

def encodeImage(pixels,byteArray):
    encodedArr = pixels 
    #print(encodedArr)
    colour = 0
    numPixel = 0
    for RGB in encodedArr:
        for c in RGB:
            if(colour==3):
                colour=0
                numPixel= numPixel+1
            andByte = 254  #1111 1110
            x =int(pixels[numPixel][colour]) & int((andByte))
            encodedArr[numPixel][colour] = int('0b' + str(bin(x)[2:]),2)
            colour = colour +1
    #print(encodedArr) 

    colour = 0
    numPixel = 0
    for byte in byteArray:
        for bit in byte:
            if(colour==3):
                colour=0
                numPixel= numPixel+1
            if(int(bit) == 0):
                andByte = 254
                x =int(pixels[numPixel][colour]) & int((andByte))
            elif(int(bit) == 1):
                orByte = 1
                x = int(pixels[numPixel][colour]) | int((orByte))
            encodedArr[numPixel][colour] = int('0b' + str(bin(x)[2:]),2)
            colour = colour +1
    return encodedArr
    '''
    print(byteArray)
    for l in range(len(encodedArr)):
        encodedArr[l] =tuple(encodedArr[l])
    return encodedArr
'''
def saveImage(encodeArr,outputName,width,height): 
    im = Image.new('RGB', (width,height))
    imageSize=[]
    for x in range(width*height):
        imageSize.append(tuple(encodeArr[x]))
    im.putdata(imageSize)
    im.save(outputName, "PNG")
    np.savetxt(outputName[:-3]+ ".txt", encodeArr, fmt='%d', delimiter=" ")

def string2bits(s):
    return [bin(ord(x))[2:].zfill(8) for x in s]

#def bits2string(b=None):
#    return ''.join([chr(int(x, 2)) for x in b])

def getInput():
    outputName =""
    if len(sys.argv) >1:	
        for argNum in range(len(sys.argv)):
            if (sys.argv[argNum].upper().find("-I")>-1):
                ImageName = sys.argv[argNum+1]
            elif(sys.argv[argNum].upper().find("-O") >-1):
                outputName =sys.argv[argNum+1]
            elif(sys.argv[argNum].upper().find("-M")>-1):
                message =sys.argv[argNum+1]         
            else:
                continue
                #print("missing arguments")
    return ImageName,outputName,message

def makeCOE(encodedArr,width,height):
    temp = []
    s = "memory_initialization_radix=10;\n"
    s = s+ "memory_initialization_vector="
    for RGB in range(width*height):
        for colour in encodedArr[RGB]:
            #print(str(colour))
            s = s + str(colour) + ","
    s = s[:-1]
    s = s +";"
    return s

def saveCOE(fName,coe):
	try:
		with io.open(fName, "w", encoding="utf-8") as f:
			f.write(coe)
			f.close()
	except UnicodeEncodeError: 
		print("UnicodeEncodeError")
		f.close()

def main():
    ImageName,outputName,message = getInput()
    print("Length of Message:", len(message))
    print("Minimum number of bits required:", len(message)*8)
    pixels,width,height = loadImage(ImageName)
    print("Image Dimensions:",width,"x", height)
    print("Number of pixels:",len(pixels))
    print("Number of RGB:",len(pixels)*3)
    byteArray = string2bits(message)
    encodedArr = encodeImage(pixels,byteArray)
    #print("Length of encodedArray:",len(encodedArr))
    coe = makeCOE(encodedArr,width,height)
    saveCOE(outputName[:-3] +"coe", coe)
    saveImage(encodedArr,outputName,width,height)

main()
