
use strict;
use Mebius::Basic;

my(@insert,$all_line,$file_num);

my($init_directory) = Mebius::BaseInitDirectory();
my $get_directory ="${init_directory}_histories/";
my(@dir) = Mebius::Directory::get_directory($get_directory);

my($main_table_name) = Mebius::History::main_table_name();
Mebius::DBI::drop_table(undef,$main_table_name);
Mebius::History::create_main_table();

	foreach my $dir (@dir){

		my($log_type,$i);

		my(@dir2) = Mebius::Directory::get_directory("$get_directory$dir");

		print "\nDir: $dir\n\n";

			if($dir =~ /_([0-9a-z]+)$/){ $log_type = $1; } else{ die($dir); }

			# 各ディレクトリ
			foreach my $file (@dir2){

				my(%data,$target);
				$i++;
				$file_num++;

					if($file =~ /^(.+?)_/){ $target = $1 } else { die; }

				$data{'type'} = $log_type;
				$data{'unique_target'} = "$log_type-$target";
				$data{'target'} = $target;

				print "File: $dir$file\n";

				# ファイルを開く
				open(IN,"<","$get_directory$dir/$file");
				chomp(my $top = <IN>);
					while(<IN>){
						chomp;
						$all_line++;
						print "file-num: $file_num / line $all_line\n";
						(undef,$data{'concept'},$data{'subject'},$data{'thread_number'},$data{'res_number_histories'},$data{'bbs_kind'},$data{'bbs_title'},undef,$data{'my_regist_time'},$data{'server_domain'},undef,$data{'handle'},undef,$data{'deleted_resnumber_histories'},undef,undef,undef,undef,undef,$data{'last_read_thread_time'},$data{'last_read_res_number'}) = split(/<>/);

						my($data_utf8) = Mebius::Encoding::hash_to_utf8(\%data);
						my $column = Mebius::History::main_table_column();
						my($data_utf8_adjusted) = Mebius::DBI::adjust_set($data_utf8,$column);
						push @insert, $data_utf8_adjusted;

					}
				close(IN);

				if(rand(5000) < 1){
					Mebius::DBI::insert(undef,$main_table_name,\@insert);
					@insert = undef;
				}

			}

	}

	if(@insert){
		Mebius::DBI::insert(undef,$main_table_name,\@insert);
	}

print "all line : $all_line\n";

exit;
