use Socket;

if( $#ARGV != 1 ){
    print "## Usage   : perl convert.pl [input_file] [county_list_file]\n";
    print "## Example : perl convert.pl nic_all list-en1-semic-3.txt\n";
    exit 0;
}

# Read country name into Hash
%country_list = ();
open( IN, "$ARGV[1]" );
while( $line = <IN> ){

    if( $line =~ /.+;\w{2}/ ){

        @array = split( ';', $line );

        # Get country name
        $country_name = $array[0];

        # Get country code
        $country_code = substr($array[1], 0, 2);

        # Add
        $country_list{ $country_code } = $country_name;
    }
}
close( IN );

$line_num = 0;
@lines = ();

open( IN, "$ARGV[0]" );
while( $line = <IN> ){
    $lines[$line_num] = $line;
    $line_num++;
}

for( $i = 0; $i < $line_num; $i++ ){

    $line = $lines[$i];

    if( $line =~ /\|ipv4\|\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}/ ){

        @column = split( '\|', $line );

        # Get start address
        $start_addr = $column[3];

        # Get country code
        $country_code = $column[1];
        if( $country_code eq '' ){
            print "## Country code is null -> $country_code at line ".($i+1)."\n";
            exit 1;
        }

        # Get IP number
        $addr_number = $column[4];

        # Get expected next start address
        $expected_next_start_addr_n = vec(inet_aton($start_addr), 0, 32) + $addr_number;

        $a1 = ($expected_next_start_addr_n & 0xff000000) >> 24;
        $a2 = ($expected_next_start_addr_n & 0x00ff0000) >> 16;
        $a3 = ($expected_next_start_addr_n & 0x0000ff00) >> 8;
        $a4 =  $expected_next_start_addr_n & 0x000000ff;

        $expected_next_start_addr = "$a1.$a2.$a3.$a4";

        #print "# start_addr   : $start_addr\n";
        #print "# country_code : $country_code\n";
        #print "# addr_number  : $addr_number\n";

        # Check subsequent lines
        $current_i = $i;
        for( $j = $current_i + 1; $j < $line_num; $j++ ){

            # Get next line
            $next_line = $lines[$j];

            @next_line_column = split( '\|', $next_line );

            # Get next line start addr
            $next_start_addr = $next_line_column[3];

            # Get next line country code
            $next_country_code = $next_line_column[1];
            if( $next_country_code eq '' ){
                print "## Country code is null -> $next_country_code at line ".($i+1)."\n";
                exit 1;
            }

            # Get IP number
            $next_addr_number = $next_line_column[4];

            #print "## expected_next_start_addr : $expected_next_start_addr\n";
            #print "-> next_start_addr          : $next_start_addr\n";
            #print "-> next_country_code        : $next_country_code\n";
            #print "-> next_addr_number         : $next_addr_number\n";

            # Compare 'next line start addr' and 'saved next line start addr'
            if( $next_start_addr eq $expected_next_start_addr && $next_country_code eq $country_code ){

                # Add next addr number
                $addr_number += $next_addr_number;

                # increment line
                $i++;

                # Update expected next start addr
                $expected_next_start_addr_n = vec(inet_aton($start_addr), 0, 32) + $addr_number;

                $a1 = ($expected_next_start_addr_n & 0xff000000) >> 24;
                $a2 = ($expected_next_start_addr_n & 0x00ff0000) >> 16;
                $a3 = ($expected_next_start_addr_n & 0x0000ff00) >> 8;
                $a4 =  $expected_next_start_addr_n & 0x000000ff;

                $expected_next_start_addr = "$a1.$a2.$a3.$a4";
            }
            else{
                #print "=> break : $next_start_addr != $expected_next_start_addr || $next_country_code != $country_code\n";
                last;
            }
        }

        #print "### start_addr   : $start_addr\n";
        #print "### country_code : $country_code\n";
        #print "### addr_number  : $addr_number\n";

        # Get end address
        $end_addr_n   = vec(inet_aton($start_addr), 0, 32) + $addr_number - 1;

        $a1 = ($end_addr_n & 0xff000000) >> 24;
        $a2 = ($end_addr_n & 0x00ff0000) >> 16;
        $a3 = ($end_addr_n & 0x0000ff00) >> 8;
        $a4 =  $end_addr_n & 0x000000ff;

        $end_addr = "$a1.$a2.$a3.$a4";

        # Get country name
        $country_name = $country_list{ $country_code };
        if( $country_name eq '' ){
            print "## Country name not defined -> $country_code\n";
            print "## You can define extra country info in ./conf/country.\n";
            exit 1;
        }

        # Substring before ','
        @substr = split( ',', $country_name );
        $country_name = $substr[0];
        $country_name =~ s/'/\\'/g;

        # Output
        print "$start_addr,$end_addr,$country_code,$country_name\n";
    }

}
close( IN );
