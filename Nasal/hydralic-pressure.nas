//* Example Nasal script listening to a switch
setlistener("controls/hydraulics/pressure", func {
    if (cmdarg().getBoolValue()) {
       print("turned on");
     } else {
        print("turned off");
     }
 });
