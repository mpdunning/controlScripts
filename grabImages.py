#!/usr/bin/env python
# grabImages.py: Saves images to disk.
# mdunning 2/10/16

from epics import caput,PV
from time import sleep
#import datetime,os,sys,math
import datetime,os,sys,subprocess


def show_usage():
    "Prints usage"
    print 'Usage: %s %s' %(sys.argv[0], args)

def grabImages(cameraPvPrefix, grabImagesN, grabImagesPlugin='TIFF1', grabImagesFilepath=''):
    if grabImagesFilepath=='':
        grabImagesFilepath=os.environ['NFSHOME'] + '/profileMonitor/grabImages/' + timestamp('year') + '/' + timestamp('today') +'/' + cameraPvPrefix
        #grabImagesFilepath='/home/nlcta/profileMonitor/grabImages/' + timestamp('year') + '/' + timestamp('today') +'/' + cameraPvPrefix
    if not os.path.exists(grabImagesFilepath): os.makedirs(grabImagesFilepath)
    if grabImagesPlugin=='TIFF1':
        fileExt='.tif'
    elif grabImagesPlugin=='JPEG1':
        fileExt='.jpg'
    else:
        fileExt='.img'
    imagePvPrefix=cameraPvPrefix + ':' + grabImagesPlugin
    PV(imagePvPrefix+':EnableCallbacks').put(1)
    # PV().put() seems to need a null terminator when putting strings to waveforms.
    PV(imagePvPrefix+':FilePath').put(grabImagesFilepath + '\0')
    PV(imagePvPrefix+':FileName').put(cameraPvPrefix + '\0')
    PV(imagePvPrefix+':AutoIncrement').put(1)
    PV(imagePvPrefix+':FileWriteMode').put(1)
    PV(imagePvPrefix+':AutoSave').put(1)
    PV(imagePvPrefix+':FileNumber').put(1)
    numCaptPv=PV(imagePvPrefix+':NumCapture')
    # Must define the following PVs before capturing, or else it slows things down
    templatePv=PV(imagePvPrefix+':FileTemplate')
    capturePv=PV(imagePvPrefix+':Capture')
    if len(sys.argv) > 3 and sys.argv[3] == '--fast':
        numCaptPv.put(grabImagesN)
        imageFilenameTemplate='%s%s_%3.3d' + fileExt
        templatePv.put(imageFilenameTemplate + '\0')
        capturePv.put(1,wait=True)
    else:
        numCaptPv.put(1)
        for i in range(grabImagesN):
            # Set FileTemplate PV and then grab image
            imageFilenameTemplate='%s%s_' + timestamp('us') + '_%3.3d' + fileExt
            templatePv.put(imageFilenameTemplate + '\0')
            capturePv.put(1,wait=True)

def timestamp(format='s'):
    "Formatted timestamp"
    if format=='us' or format==1:
        return(datetime.datetime.now().strftime('%Y%m%d_%H%M%S.%f'))
    elif format=='ms':
        return(datetime.datetime.now().strftime('%Y%m%d_%H%M%S.%f'[:-3]))
    elif format=='s' or format==0:
        return(datetime.datetime.now().strftime('%Y%m%d_%H%M%S'))
    elif format=='today':
        return(datetime.datetime.now().strftime('%Y%m%d'))
    elif format=='year':
        return(datetime.datetime.now().strftime('%Y'))
    elif format=='month':
        return(datetime.datetime.now().strftime('%Y%m'))


if __name__ == "__main__":
    args='CAM_PVPREFIX NUMBER_OF_IMAGES [--fast]'
    if len(sys.argv) > 4:
        show_usage()
        sys.exit(1)
    cameraPvPrefix=sys.argv[1]
    if ':' in cameraPvPrefix: cameraPvPrefix=cameraPvPrefix.replace(':','')
    grabImagesN=int(sys.argv[2])
    grabImages(cameraPvPrefix, grabImagesN)

##################################################################################################################

exit

