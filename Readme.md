To run the app please follow the following steps :
1. Clone the repository in your local machine.
2. Install python(version 3.10.4 or higher) in your machine (if not already installed) follow steps in given link to install python https://www.digitalocean.com/community/tutorials/install-python-windows-10
3. Install all requirements stated in requirements.txt in the Folder API. Follow steps in given link to guide yourself about installing libraries/packages in python https://docs.python.org/3/installing/index.html  (Please install the same version as specified in the requirements.txt). (you can also run pip install -r "path/to/requirements.txt" in cmd to install all required packages together. Also it is recommended to create a new python environment refer following link for help creating a new python environment https://packaging.python.org/en/latest/tutorials/installing-packages/#creating-virtual-environments)
4. Follow steps following link to install and setup andrion studio to run the flutter app https://radixweb.com/blog/install-flutter-on-windows-mac-and-android

Follow below steps after installing Andriod Studion and Python (with libraries) : 
Connect both your laptop and mobile with the same network. Keep them connected for all steps below until you close the app.
Connect you mobile to your laptop using a cable and in your mobile enable usb debugging. Follow steps in given link to enable developer option and usb debugging https://www.embarcadero.com/starthere/xe5/mobdevsetup/android/en/enabling_usb_debugging_on_an_android_device.html
In the usb debugging make sure to enable "Install via USB" option so that flutter app can be installed in you phone.

1. Open cmd (and activate where you have installed all libraries specified in the requirements.txt. If you have not created a new environment ignore this and follow next steps)
2. Navigate to the folder API(cloned by this repository) using cd command
3. Run the command python app.py in the folder API. If the file runs successfully a window will open with text similar given below. Do not close this window until you close the app.
  * Serving Flask app 'app' (lazy loading)
  * Environment: production
    WARNING: This is a development server. Do not use it in a production deployment.
    Use a production WSGI server instead.
  * Debug mode: off
  Note : If above text does not appear then either you have not activated correct python environment, not installed all required libraries or not installed python.
4. If it runs successfully open logs.txt file in API folder and copy the http link on the last line (the link will be somthing like  http://192.168.10.5:5000 please do not copy the link similar to http://127.0.0.1:5000)
5. Open folder named "flutter_app" in Andriod studio using Open project option and open main.dart in the folder "flutter_app/lib" if not already open. If you cannot see the project navigation pane press Alt + 1 of click of "project" written vertically on left egde of the window. If you still cannot see the folder lib or flutter_app then drop down above says Project and not says anything else.
6. Search for the lines String url_base = "http://192.168.10.5:5000/" and replace it with String url_base = "link_copied_in_step4/". Please add a forward slash "/" after the copied link so that the link looks like "http://192.168.10.5.5000/" instead of http://192.168.10.5.5000. There will 2 places in the whole file where this change is to be done.
7. Make sure that you phone's name is visible in the top and it is not writtedn <no device selected>. If that is the case then either you phone is not connected to laptop using a cable or usb debugging is not enabled in you phone.
8. Open terminal by pressing Alt+F12 if not already open.
9. Type flutter run command in the terminal to run the app.
It will take some time and after a while a pop up will open in you phone to allow installation of a app. Click allow.
After you click allow the app will open in you phone automatically after a while. 
You can now use the app locally. 

Please make sure that your phone and laptop is connected to same wifi or network
Make sure that you phone is connected to you laptop via a USB cable and USB debugging is enabled along with install vis USB option.
Make sure that the above 2 conditions remain intact until you close the app.



    




