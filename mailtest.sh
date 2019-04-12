#!/usr/bin/php
<?php
/*








 ** DO NOT EDIT THIS FILE. MAKING ANY CHANGES WILL BREAK NEMS!!! **


 ** Remember, this is a git repository, so if you edit ANY files **
 ** in this folder, git will no longer update.                   **






























*/

$user=trim(shell_exec('whoami'));
if ($user != 'root') die('You cannot run this program as ' . $user . '. Please use sudo.' . PHP_EOL);

$CONTACTEMAIL=@trim(@$argv[1]);
if (!filter_var($CONTACTEMAIL, FILTER_VALIDATE_EMAIL)) {
  echo 'Usage: ./mailtest.sh youremail@yourdomain.com' . PHP_EOL;
  exit();
}
echo 'Please wait...' . PHP_EOL;
$ver = shell_exec('/usr/local/bin/nems-info nemsver');
if ($ver >= 1.5) {
  $username = shell_exec('/usr/local/bin/nems-info username');
  echo shell_exec('/usr/local/nagios/libexec/nems_sendmail_service "TEST NOTIFICATION" "NEMS" "Nagios Enterprise Monitoring Server" "UP" "127.0.0.1" "The test email was sent successfully." "' . date('Y-m-d H:i:s') . '" "nems-mailtest" "SUCCESS" "' . $CONTACTEMAIL . '" "361" "0.061" "1" "0" "0" "' . strtotime('now') . '" "' . strtotime('now') . '" "0" "" "' . $username . '" "nems-mailtest successfully sent this message." "" "0" "1" "1" "' . $username . '"');
  exit();
} elseif ($ver >= 1.4) {
  $resource = file('/usr/local/nagios/etc/resource.cfg');
} else {
  $resource = file('/etc/nagios3/resource.cfg');
}
if (is_array($resource)) {
  foreach ($resource as $line) {
    if (strstr($line,'$=')) {
      $tmp = explode('$=',$line);
      if (substr(trim($tmp[0]),0,1) == '$') { // omit comments (eg., starts with # instead of $)
        $variable_name = str_replace('$','',trim($tmp[0]));
        $$variable_name = trim($tmp[1]);
      }
    }
  }
}
$HOSTADDRESS = shell_exec('/usr/local/bin/nems-info ip');
$HOSTNAME = shell_exec('hostname');
$LONGDATETIME = date('r');

$error = ''; // create a list of errors
if (isset($USER5) && strlen($USER5) > 0) {
  if (!filter_var($USER5, FILTER_SANITIZE_EMAIL)) {
    $error .= '- Email address in NEMS SST is invalid.' . PHP_EOL;
  }
} else {
  $error .= '- Email address missing from NEMS SST.' . PHP_EOL;
}

if (strlen($CONTACTEMAIL) > 0) {
  if (!filter_var($CONTACTEMAIL, FILTER_SANITIZE_EMAIL)) {
    $error .= '- Email address in ' . $CONTACTEMAIL . ' is invalid.' . PHP_EOL;
  }
}

if (isset($USER5) && $USER5 == $CONTACTEMAIL) $error .= '- You need to send to a different email address: same as sender.' . PHP_EOL;

if (!isset($USER7)) $error .= '- Missing SMTP server in NEMS SST.' . PHP_EOL;
if (!isset($USER9)) $error .= '- Missing SMTP username in NEMS SST.' . PHP_EOL;
if (!isset($USER10)) $error .= '- Missing SMTP password in NEMS SST.' . PHP_EOL;

// Add slashes to password
$USER10 = str_replace('"','\"',$USER10);

// Die on errors
if (strlen($error) > 0) die($error . PHP_EOL . 'Aborted.' . PHP_EOL);

$command = "/usr/bin/printf \"%b\" \"***** NEMS Test Email *****\n\nNotification Type: Test\nHost: $HOSTNAME\nAddress: $HOSTADDRESS\n\nDate/Time: $LONGDATETIME\n\" | /usr/bin/sendemail -v -s \"$USER7\" -xu \"$USER9\" -xp \"$USER10\" -t \"$CONTACTEMAIL\" -f \"$USER5\" -l /var/log/sendemail -u \"** NEMS Test Email: $HOSTNAME **\" -m \"***** NEMS Test Email *****\n\nNotification Type: Test\nHost: $HOSTNAME\nAddress: $HOSTADDRESS\n\nDate/Time: $LONGDATETIME\n\"";
$output = shell_exec($command);
echo $output;
shell_exec('chown nagios:nagios /var/log/sendemail'); // Log gets created as running user. Fix.

?>
