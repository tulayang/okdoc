# Dragon Deployment Architecture

1. create node

2. list node

3. list images

4. create cluster

5. start cluster

6. deploy containers




```?
C1  ---------+   +------------  PS1  -- DM -- D1 -- D2    
             |   |                      |           |  
             |   |                      +-----------+
             |   |                        
             |   |
C2  ---------  S  ------------  PS2  -- DM -- D1 -- D2
             |   |                      |           |  
             |   |                      +-----------+
             |   |
             |   |
C3  ---------+   +------------  PS3  -- DM -- D1 -- D2
                                        |           |  
                                        +-----------+  
```