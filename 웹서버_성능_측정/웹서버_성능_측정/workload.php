<HTML>
<HEAD>
<TITLE>PHP WORKLOAD TEST</TITLE>
</HEAD>
<BODY>
<?php
echo "<p><br><br></p>";
echo "This web server name is " . $_SERVER['SERVER_SOFTWARE'];
echo "<p>&nbsp;</p>";

function get_microtime() {
        list($usec, $sec) = explode(" ", microtime());
        $time = (float)$usec + (float)$sec;
        return $time;
}

#$start_memory_page = memory_get_usage();
$start_time = get_microtime();

$i=1;
$j=1;
$result=0;

for($i=1; $i<=10; $i++) {
        for ($j=1; $j<=1000000; $j++){
                $result=$i*$j;
#               echo  $i . "*" . $j . "=" . $result . " <br>";
        }
#       echo "Completed calculation of " . $i . " looping";
}
#unset($data);

#$finish_memory_page=memory_get_usage();
$finish_time=get_microtime();

$total_time = round(($finish_time - $start_time), 3);

#echo "<br><br>";
#echo "start_memory : " . $start_memory_page;
#echo "<br>";
#echo "finish_memory : " . $finish_memory_page;
#echo "<br><br>";
echo "Page generated in " . $total_time . "sec";
?>
</BODY>
</HTML>
