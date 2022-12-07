# Jay Soni
# Het Bhavsar
from flask import Flask, request, send_file
from image_process import *
import logging

app = Flask(__name__)

func_mapp = {
    
    "Ridge Detection": edge_detect,
    "Gaussian Blur":gaussianBlur,
    "Average Blur": averaging,
    "Negation" : negate,
    "Opening": opening,
    "Canny Edge Detection":canny_edge,
    "Black Hat" : blackHat,
    "Morphological Gradient" : morph,
    "Thresholding":imageFunc,
    "Erosion" : erosion,
    "Dilation" : dilation,
    "Sobel Edge Detector": sobel,
    "Closing":closing,
    "Harris Corner Detection":harris,
    "Max Filter":maximum,
    "Median Blur":median_blur,
    "Laplacian":laplacian,
    "Sobel Scharr":sobel_scharr,
    "Sharpen":sharpen



}

param_mapp = {
    "Ridge Detection": {},
    "Gaussian Blur" : {"ksize":"int"},
    "Average Blur" : {"ksize":"int"},
    "Negation": {},
    "Opening":{"ksize":"int"},
    "Canny Edge Detection" : {"threshold1":"int","threshold2":"int","apertureSize":"int"},
    "Black Hat":{"ksize":"int"},
    "Morphological Gradient":{"ksize":"int"},
    "Thresholding":{"thresh":"int","max_value":"int"},
    "Erosion":{"kernelSize":"int","iterations":"int"},
    "Dilation":{"ksize":"int","iterations":"int"},
    "Sobel Edge Detector":{},
    "Closing":{"ksize":"int"},
    "Harris Corner Detection":{},
    "Max Filter":{},
    "Median Blur":{"ksize":"int"},
    "Laplacian":{"ksize":"int"},
    "Sobel Scharr" : {},
    "Sharpen":{}
}


@app.route("/")
def home():
    return "hello"

@app.route("/params/<string:operation>")
def get_params(operation):
    if operation in func_mapp.keys():
        return param_mapp[operation]
    else:
        return "Not Found"

@app.route("/operations")
def list_of_operations():
    print(str(func_mapp.keys()))
    print(str((sorted(list(func_mapp.keys())))))
    return str((sorted(list(func_mapp.keys())))).replace('\'','"')


@app.route("/process", methods = ["POST"])
def process():
    try:
        img = request.files.get("img","")
        print("Args : ",request.args)
        # print("Headers : ",request.headers)
        print("Form data",request.form)
    except Exception as exception:
        logger.warning("Unable to get image from given request due to the exception {} : {}".format(type(exception).__name__, exception))
        print("Unable to get image from given request due to the exception {} : {}".format(type(exception).__name__, exception))
        return None
    print("hello")
    try:
        operation = request.form.get("operation")
    except Exception as exception:
        logger.warning("Unable to get required operation from given request due to the exception {} : {}".format(type(exception).__name__, exception))
        print("Unable to get required operation from given request due to the exception {} : {}".format(type(exception).__name__, exception))
        return None
    print("here")
    # print(operation)
    params = dict(request.form)
    params.pop("operation")
    # print(params)
    to_remove = []
    for i in params:
        # print(i)
        if param_mapp[operation][i] == "int":
            print("in if")
            if params[i] == "null":
                to_remove.append(i)
                continue
            params[i] = int(params[i])
        print("out of if")
    
    for i in to_remove:
        del params[i]
    # print(params)
    print("Params : ",params,"-")
    if operation in func_mapp.keys():
        extension = img.content_type.split("/")[1]
        img.save("raw.{}".format(extension))
        img = cv2.imread("raw.{}".format(extension))
        # print(img)
        processed = func_mapp[operation](img,**params)
        # print(processed)
        cv2.imwrite("processed.{}".format(extension), processed)
        
        return send_file("processed.{}".format(extension))
    else:
        logger.warning("Given operation {} not in list of available operations".format(operation))
        return None

if __name__ == "__main__":
    # print(list_of_operations())
    try:
        logging.basicConfig(format="%(asctime)s — %(name)s — %(levelname)s — %(funcName)s:%(lineno)d — %(message)s)",filename="logs.txt",filemode="a")
        logger = logging.getLogger()
        app.run(debug = False,host = "0.0.0.0" ) #host = "0.0.0.0" to run on real device(connected via usb debugging) , host = "localhost" to run on andriod studio emulator
    except Exception as exc:
        input("Unable to run app due to the exception {} : {}".format(type(exc).__name__, exc))


