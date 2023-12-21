import base64
import sys
print(base64.b64decode(sys.argv[1]).hex())
