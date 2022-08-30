## Sharing data among groups
https://docs.alliancecan.ca/wiki/Sharing_data
```
setfacl -R -d -m group:def-lsigal:rwx $FOLDER_PATH
```

## Sharing to a user
To allow read and write access to a single user in a whole subdirectory, including new files created in it, you can run the following commands:

```
setfacl -d -m u:gabrielh:rwX /home/muchenli/projects/def-lsigal/muchenli
setfacl -R -m u:gabrielh:rwX /home/muchenli/projects/def-lsigal/muchenli
```
