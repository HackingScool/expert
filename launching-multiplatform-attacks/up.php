<?php
  // $up_dir is the directory to store the information from 
  // the remote computers
  $up_dir = "/var/www/html/info/";
  
  // $up_file is the filename created for the different payloads  
  $up_file = $up_dir . basename($_FILES['system-info']['name']);
  
  // we move the uploaded file with a temporary name to the 
  // $up_file 
  move_uploaded_file($_FILES['system-info']['tmp_name'], $up_file);
?>
