To use the gui tool will need xhost on mac 

1. Expose x11(xquartz) to docker

    xhost + 127.0.0.1

2. Run the docker and open terminal

    docker run -it -e DISPLAY=host.docker.internal:0 -v /tmp/.X11-unix:/tmp/.X11-unix 
    
    my-docker-image /bin/bash

3. Run Config tool

    python3 config_tool.py

4. Check data was saved

    cat data.json
