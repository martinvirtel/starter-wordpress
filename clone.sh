#! /bin/bash
 
make install-local 
make cli CLI='plugin install all-in-one-wp-migration'
make cli CLI='plugin activate all-in-one-wp-migration'
sudo mkdir -p html/wp-content/ai1wm-backups/
sudo cp ../stories-wordpress-3/html/wp-content/ai1wm-backups/dpa-stories.newsradar.org-20180613-063433-986.wpress html/wp-content/ai1wm-backups/
sudo mkdir -p html/wp-content/plugins/all-in-one-wp-migration/storage
sudo chmod 0777 html/wp-content/plugins/all-in-one-wp-migration/storage
make cli CLI='wp ai1wm restore dpa-stories.newsradar.org-20180613-063433-986.wpress'

