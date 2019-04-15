
use strict;
use Mebius::Text;
use Mebius::BBS;
use Mebius::BBS::Path;
use Mebius::Page;
use Mebius::RenewStatus;
use File::Copy;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# ���e�������擾 / �X�V 
#-----------------------------------------------------------
sub get_reshistory{

# �錾
my($type,$file,$use,$postdata,$maxview_index,undef,$maxview_one,$maxview_topics,$maxget_follow) = @_;
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my(%type,%post);
foreach(split(/\s/,$type)){	$type{$_} = 1; } # �����^�C�v��W�J
my(%got_topics); # ������Ȋ����ŁA�����ċǏ������Ȃ��� mod_perl �ŕs����H
(undef,undef,undef,%got_topics) = @_ if($type =~ /TOPICS-get-only/);
my(undef,undef,undef,%renew) = @_ if($type =~ /(Make-account|Use-renew-hash)/);
my($pi_sub,$pi_postnumber,$pi_resnumber,$prealmoto,$ptitle,$pserver_domain,$pid,$pcomment,$pcharge_ressecond,$pcharge_postsecond,$phandle,$pencid) = split(/<>/,$postdata) if ($postdata);
($post{'subject'},$post{'thread_number'},$post{'res_number'},$post{'bbs_kind'},$post{'bbs_title'},$post{'server_domain'},$post{'id'},$post{'comment'},undef,undef,$post{'handle'},undef) = split(/<>/,$postdata) if ($postdata);
my(undef,undef,undef,$delete_realmoto,$delete_thread_number,$delete_res_number) = @_ if($type =~ /Delete-(thread|res|handle)/);
my(undef,undef,undef,$repair_realmoto,$repair_thread_number,$repair_res_number) = @_ if($type =~ /Repair-(thread|res|handle)/);
my($i,$i_index,$hit_one,$hit_index,$i_topics,$hit_follow,$top,$newkey,@newkey2,$RENEW_STATUS_FLAG);
my($history_file,$max_line,$index_line,$return_index_line,$index_flow,$one_line,$plength,$file2,$filehandle1,$deadlink_check_flag);
my(@follow_bbs,$topics_line,@krchain_line,@renew_line,@topics,$myhistory_flag,%history);
my(@bbslist,%bbslist,$lastrestime_bbs,$search_moto,$keep_res_number_histories,$tall_thread_buffer,$file_nothing_flag,$renew_status_interval_second);
my($pdeleted_resnumber_histories,$pkeylevel,$directory2,$new_resnumber_histories,$hit_get_thread,$gethost,%renew_line_redun,$hit_renew,$read_thread_hit_flag,$join_file_flag,@file,$thread_status_from_dbi,$thread_status_renew_flag,@unique_target_for_sql);
my $time = time;
my($q) = Mebius::query_state();
if($type =~ /Get-lastres-time/){ (undef,undef,undef,$search_moto) = @_; }
my($my_use_device) = Mebius::my_use_device();
our($title,$secret_mode,$concept,$subtopic_mode,$moto,$cnumber,$cookie,$k_access,$kaccess_one,$addr,$agent,$css_text,$xclose,$postbuf,$script,$encid);

# �f�B���N�g����`
my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();
my $directory1 = "${share_directory}_histories/";

# �ݒ�
my $data_move_concept = "Data-moved-from-server1-2012.12.06";

	# �{�b�g�̏ꍇ�A���^�[��
	if(Mebius::Device::bot_judge() && $type =~ /RENEW|My-file/){ return(); }

	# �^�C�v���w��̏ꍇ�A���ϐ������ƂɃ^�C�v��������
	if($type =~ /My-file/ && $type !~ /(ACCOUNT|Open-account|CNUMBER|KACCESS_ONE|HOST|TRIP|ENCID|HANDLE|ISP)/){

			# ���ł��z�X�g�����g���Ă��܂��ƁA�c��ȃA�N�Z�X������z�X�g�����t�������Ă��܂����A
			# �S�����l�̉{�����������邱�Ƃ��o���Ă��܂��A�Z�L�����e�B�I�ɖ�肪����
			if($type =~ /RENEW|Allow-host/){ ($gethost) = Mebius::GetHostWithFile(); }

			if($my_account->{'login_flag'}){ $type .= " ACCOUNT"; }
			elsif($cnumber && $cookie){ $type .= " CNUMBER"; }
			elsif($kaccess_one){ $type .= " KACCESS_ONE"; }
			elsif($gethost && !$k_access){ $type .= " HOST"; } 
			else{ return; }

	}

	# ���e�����̃^�C�v���`
	if($type =~ /Crap-file/){
		$history{'history_type'} = "crap";
	} elsif($type =~ /Check-file/){
		$history{'history_type'} = "check";
	} else {
		$history{'history_type'} = "res";
	}

	# �A�J�E���g�L�^�t�@�C���̏ꍇ
	if($type =~ /ACCOUNT/){
		$max_line = 100;
			if($file eq "" && $type =~ /My-file/){ $file = $my_account->{'id'}; }
		$file2 = $file;
			if(Mebius::Auth::AccountName(undef,$file)){ return(); }
			if($file eq ""){ return; }
			if($type =~ /Crap-file/){
				$directory2 = "${directory1}_craphistory_account/";
				$history_file = "${directory2}${file}_craphistory_account.log";
			}
			elsif($type =~ /Check-file/){
				$directory2 = "${directory1}_checkhistory_account/";
				$history_file = "${directory2}${file}_checkhistory_account.log";
			}
			else{
				$directory2 = "${directory1}_reshistory_account/";
				$history_file = "${directory2}${file}_reshistory_account.log";
			}

			if($file2 eq $my_account->{'id'}){ $myhistory_flag = 1; }
		$history{'file_type'} = $history{'access_target_type'} = "account";
		$history{'file_type_japanese'} = "�A�J�E���g";
	}

	# �N�b�L�[�L�^�t�@�C���̏ꍇ
	elsif($type =~ /CNUMBER/){
		$max_line = 100;
			if($file eq "" && $type =~ /My-file/){
					if($type{'Cnumber-hash'}){ $file = $cnumber; }
					else{ $file = $cnumber; }
			}

		$file2 = $file;
		$file =~ s/[^0-9a-zA-Z]//g;
			if($file eq ""){ return; }
			if($type =~ /Crap-file/){
				$directory2 = "${directory1}_craphistory_cnumber/";
				$history_file = "${directory2}${file}_craphistory_cnumber.log";

			}
			elsif($type =~ /Check-file/){
				$directory2 = "${directory1}_checkhistory_cnumber/";
				$history_file = "${directory2}${file}_checkhistory_cnumber.log";

			}
			else{
				$directory2 = "${directory1}_reshistory_cnumber/";
				$history_file = "${directory2}${file}_reshistory_cnumber.log";
			}
			if($file2 eq $cnumber){ $myhistory_flag = 1; }

			$history{'file_type'} = "cookie";
			$history{'access_target_type'} = "cnumber";

	}

	# �ő̎��ʔԍ��t�@�C���̏ꍇ
	elsif($type =~ /KACCESS_ONE/){

		# �Ǐ���
		my($mobile_id,$mobile_uid);

		$max_line = 100;

		# �A�N�Z�X�f�[�^���擾
		my($access) = Mebius::my_access();

			# �����̃f�[�^��������ꍇ
			if($file eq "" && $type =~ /My-file/){
				$mobile_id = $access->{'mobile_id'};
				$mobile_uid = $access->{'mobile_uid'};
			}

			# UA�𕪉�����ꍇ
			else{
				my($device) = Mebius::device({ UserAgent => $file });
				$mobile_id = $device->{'mobile_id'};
				$mobile_uid = $device->{'mobile_uid'};
			}


			# ���^�[������ꍇ
			if($mobile_id eq "" || $mobile_uid eq ""){ return; }

		# �G���R�[�h
		my($mobile_id_encoded) = Mebius::Encode("",$mobile_id);
		my($mobile_uid_encoded) = Mebius::Encode("",$mobile_uid);


			# �����ˁI�t�@�C��
			if($type =~ /Crap-file/){
				$directory2 = "${directory1}_craphistory_kaccess_one/";
				$history_file = "${directory2}${mobile_id_encoded}_${mobile_uid_encoded}_craphistory_kaccess_one.log";
			}
			elsif($type =~ /Check-file/){
				return();
			}
			else{
				$directory2 = "${directory1}_reshistory_kaccess_one/";
				$history_file = "${directory2}${mobile_id_encoded}_${mobile_uid_encoded}_reshistory_kaccess_one.log";

			}

			if($mobile_id eq $access->{'mobile_id'} && $mobile_uid eq $access->{'mobile_uid'}){ $myhistory_flag = 1; }

			$history{'file_type'} = "mobile_uid";

	}

	# �z�X�g�t�@�C���̏ꍇ
	elsif($type =~ /HOST/){


			# �g�т̏ꍇ�̓z�X�g�����`�F�b�N���Ȃ� ( �����̃t�@�C���̏ꍇ )
			if($type =~ /My-file/ && $k_access){ return(); }

		$max_line = 100;
			if($file eq "" && $type =~ /My-file/){
				($file) = Mebius::GetHostWithFile();
				#$file = $gethost;
			}
		($file,$file2) = (Mebius::Encode("",$file),$file);
			if($file eq ""){ return; }

			if($type =~ /Crap-file/){
				$directory2 = "${directory1}_craphistory_host/";
				$history_file = "${directory2}${file}_craphistory_host.log";
			}
			elsif($type =~ /Check-file/){
				return();
			}
			else{
				$directory2 = "${directory1}_reshistory_host/";
				$history_file = "${directory2}${file}_reshistory_host.log";
			}
			if($file2 eq $gethost){ $myhistory_flag = 1; }

		$history{'file_type'} = "host";

	}

	# ISP�t�@�C���̏ꍇ
	elsif($type =~ /ISP/){

			# �g�т̏ꍇ��ISP���`�F�b�N���Ȃ� ( �����̃t�@�C���̏ꍇ )
			#if($type =~ /My-file/ && $k_access){ return(); }

		# ISP�����擾
		my($multi_host) = Mebius::GetHostWithFileMulti();

		$max_line = 500;
			if($file eq "" && $type =~ /My-file/){ $file = $multi_host->{'isp'}; } 
		($file,$file2) = (Mebius::Encode("",$file),$file);
			if($file eq ""){ return; }
		$directory2 = "${directory1}_reshistory_isp/";
		$history_file = "${directory2}${file}_reshistory_isp.log";
			if($file eq $multi_host->{'isp'}){ $myhistory_flag = 1; }

			$history{'file_type'} = "isp";

	}

	# �g���b�v�t�@�C���̏ꍇ
	elsif($type =~ /TRIP/){
		$max_line = 200;
			if($file eq ""){ return(); }
		$file =~ s/!/\//g;
		$file =~ s/~/\./g;
		($file) = Mebius::Encode("",$file);
		$directory2 = "${directory1}_reshistory_trip/";
		$history_file = "${directory2}${file}_reshistory_trip.log";
		$history{'file_type'} = "trip";
		$history{'file_type_japanese'} = "�g���b�v";
	}

	# ID�t�@�C���̏ꍇ
	elsif($type =~ /ENCID/){
		$max_line = 200;
			if($file eq ""){ return(); }
		($file) = Mebius::Encode("",$file);
		$directory2 = "${directory1}_reshistory_id/";
		$history_file = "${directory2}${file}_reshistory_id.log";
		$history{'file_type'} = "encid";
		$history{'file_type_japanese'} = "ID";
	}

	# ���J�p�̃A�J�E���g�t�@�C���̏ꍇ
	elsif($type =~ /Open-account/){
		$max_line = 200;
			if(Mebius::Auth::AccountName(undef,$file)){ return(); }
			if($file eq ""){ return(); }
		($file) = Mebius::Encode("",$file);
		$directory2 = "${directory1}_reshistory_open_account/";
		$history_file = "${directory2}${file}_reshistory_open_account.log";
		$history{'file_type'} = "open-account";
		$history{'file_type_japanese'} = "�A�J�E���g(���J)";
	}

	# �M���t�@�C���̏ꍇ
	elsif($type =~ /HANDLE/){
		$max_line = 100;
			if($file eq ""){ return(); }
		($file) = Mebius::Encode("",$file);
		$directory2 = "${directory1}_reshistory_handle/";
		$history_file = "${directory2}${file}_reshistory_handle.log";
		$history{'file_type'} = "handle";
	}

	# �^�C�v���w��̏ꍇ�A���^�[�� ( 2 )
	else{ return; }


$history{'access_target'} = $file;

	# �x���t�@�C���̏ꍇ�A�ő�s����ύX����
	if($type =~ /Crap-file|Check-file/){ $max_line = 10; }
	else { $type .= qq( Res-file); }

	# CSS��` ( �C���f�b�N�X )
	my($per_page,$per_first_page);
	if($type =~ /INDEX/){
		$css_text .= qq(
		.newres{font-size:100%;color:#f00;}
		.mylastdate{font-size:90%;color:#355;}
		th.justy,td.justy{text-align:right;}
		th{text-align:left;}
		);

		# �X�}�t�H�ł�����CSS (�}�C�y�[�W�p)
		if(!$my_use_device->{'smart_flag'}){
			$css_text .= qq(td,th{padding:0.3em 1.5em 0.3em 0em;}\n);
		}

		if($my_use_device->{'type'} eq "Mobile"){
			($per_page,$per_first_page) = Mebius::Page::InitPageNumber("Mobile-view"); 
		}
		else{
			($per_page,$per_first_page) = Mebius::Page::InitPageNumber("Desktop-view"); 
		}
	}

	# �ő�\���� / �擾���̐ݒ�
	if(!$maxview_index){ $maxview_index = $max_line; }
	if($my_use_device->{'type'} eq "Mobile" && $maxview_index > 20){ $maxview_index = 20; }

	if(!$maxview_one){ $maxview_one = 5; }
	if(!$maxview_topics){ $maxview_topics = 10; }
	if(!$maxget_follow){ $maxget_follow = 10; }

	# �t�@�C���ǂݍ���
	if($type =~ /File-check-error/){ open($filehandle1,"+<",$history_file) || main::error("���̓��e�����͑��݂��܂���B[hs001] "); }
	elsif($type =~ /File-check-return/){ open($filehandle1,"+<",$history_file) || return(); }
	else{ open($filehandle1,"+<",$history_file) || ($file_nothing_flag = 1); }

	if($file_nothing_flag && $type =~ /RENEW/){
		Mebius::Mkdir(undef,$directory1);
		Mebius::Mkdir(undef,$directory2);
		Mebius::Fileout("Allow-empty Check",$history_file);
		open($filehandle1,"+<",$history_file);
	}

	# �t�@�C�����b�N
	if($type =~ /RENEW/){ flock($filehandle1,2); }

	# �g�b�v�f�[�^
	if($type !~ /OLD/){ $top = <$filehandle1>; chomp $top; }

# �Ǐ��� ( �g�b�v�f�[�^�̒��ŁA�܂��n�b�V���Ƃ��Ĉ����Ă��Ȃ������� )
my($tunique,$tid,$tcnumber,$tpmfile,$tkaccess_one,$tk_access,$taddr,$thost,$tagent,$tlastcomment,$tcharge_ressecond,$tcharge_postsecond,$tcnumbers,$thosts,$taccounts,$tagents,$temails,$tnames,$ttrips,$tlast_deadlink_checktime,$tencids,$tall_thread);

# �g�b�v�f�[�^�𕪉�
($history{'key'},$history{'lasttime'},$history{'first_time'},$history{'renew_time'},$tunique,$tid,$tcnumber,$tpmfile,$tkaccess_one,$tk_access,$taddr,$thost,$tagent,$tlastcomment,$tcharge_ressecond,$tcharge_postsecond,$tcnumbers,$thosts,$taccounts,$tagents,$temails,$tnames,$ttrips,$tlast_deadlink_checktime,$history{'regist_count'},$tencids,$tall_thread,$history{'make_account_blocktime'},$history{'last_renew_status_time'},$history{'last_regist_time_per_hour'},$history{'all_length_per'},$history{'make_accounts'},$history{'regist_count_per'},$history{'concept'}) = split(/<>/,$top);

	# �t���O 2012/12/6 (��) ���T�[�o�[�̃f�[�^�𓝍�����
	if($history{'concept'} !~ /$data_move_concept/ && $history{'first_time'} < 1354843578 && (Mebius::Server::bbs_server_judge() || Mebius::alocal_judge())){ #$my_account->{'master_flag'}
		$type .= qq( RENEW);
		$join_file_flag = 1;
	}

	# �n�b�V������
	if(!$file_nothing_flag){ $history{'f'} = 1; }

	# �P���ԂɂP�x�X�V����� time ( ���e�������u���b�N�̂��߂ȂǂɎg�� )
	if(time > $history{'last_regist_time_per_hour'} + (1*60*60)){
		$history{'all_length_per'} = 0;
		$history{'regist_count_per'} = 0;
	}

	# �e�L�����擾���Ă̍X�V�Ԋu���` ( ���� �c ���P�ʂł͂Ȃ��h�b�h�P�ʁI )

	# ���ŋ߂̃��X�̍X�V�Ԋu���`
	if($type =~ /Allow-renew-status/){

			if($type =~ /TOPICS/){
					if(Mebius::alocal_judge()){ $renew_status_interval_second = 1*15; }
					else{ $renew_status_interval_second = 1*30; }
			}


			# ���e�X���b�h���E�X�V�p�̔���
			# && $ENV{'REQUEST_METHOD'} eq "GET"

			if($history{'f'} && $type =~ /(ACCOUNT|CNUMBER|KACCESS_ONE)/ && !Mebius::Device::bot_judge()){
				$RENEW_STATUS_FLAG = 1;

				$history{'last_renew_status_time'} = time;
			}

	}

	# �V�K�쐬���A�g�b�v�f�[�^���Ȃ��ꍇ�ɕ⊮����
	if($type =~ /RENEW/ && $type =~ /My-file/){
				if($encid eq ""){ ($encid) = main::id(); }
				if($tid eq ""){ $tid = $encid; }
				if($history{'key'} eq ""){ $history{'key'} = 1; }
				if($history{'first_time'} eq ""){ $history{'first_time'} = time; }
				if($tunique eq ""){
					my @charpass = ('a'..'z', 'A'..'Z', '0'..'9');
						for(1..10){ $tunique .= $charpass[int(rand(@charpass))]; }
				}
		}

	# �t�@�C���X�V���A���̓f�[�^���Ȃ��ꍇ�ɕ⊮����
	if($type =~ /RENEW/){
			if($pcharge_ressecond eq ""){ $pcharge_ressecond = $tcharge_ressecond; }
			if($pcharge_postsecond eq ""){ $pcharge_postsecond = $tcharge_postsecond; }
	}

	# ���n�b�V������
	if($type =~ /(Get-hash|TOPDATA)/){

			# ��{�n�b�V��
			$history{'type'} = $type;
			$history{'lastcomment'} = $tlastcomment;
			$history{'charge_ressecond'} = $tcharge_ressecond;
			$history{'charge_postsecond'} = $tcharge_postsecond;
			$history{'cnumbers'} = $tcnumbers;
			$history{'hosts'} = $thosts;
			$history{'accounts'} = $taccounts;
			$history{'agents'} = $tagents;
			$history{'names'} = $tnames;
			$history{'emails'} = $temails;
			$history{'trips'} = $ttrips;
			$history{'names'} = $tnames;
			$history{'encids'} = $tencids;
			$history{'all_thread'} = $tall_thread;
				if(!$file_nothing_flag){ $history{'f'} = 1; }

			# �ǉ��̃n�b�V�����`
			my($other_counts);
				if($type =~ /Get-hash-detail/){
					foreach(split(/\s/,$thosts)){ $history{'other_counts'}++; }
					foreach(split(/\s/,$tagents)){ $history{'other_counts'}++; }
					foreach(split(/\s/,$tcnumbers)){ $history{'other_counts'}++; }
					foreach(split(/\s/,$taccounts)){ $history{'other_counts'}++; }
				}
			($history{'first_date'}) = Mebius::Getdate(undef,$history{'firsttime'});

	}

	# ���t�@�C����W�J����
	while(<$filehandle1>){
		push(@file,$_);
	}

	# ��DBI����X�V�����擾����
	if($type =~ /Allow-renew-status/ && Mebius::Switch::dbi_new_res_history()){
		($thread_status_from_dbi) = thread_status_from_dbi(\@file);
	}

my $old_file_to_new_dbi_concept = "Old-file-to-new-dbi-2013-11-08";

	if($type =~ /Old-file-to-new-dbi/ && $history{'first_time'} && $history{'first_time'} < 1383798383 + (24*60*60) ){
			if($history{'concept'} =~ /$old_file_to_new_dbi_concept/ && !Mebius::alocal_judge()){
				close($filehandle1);
				return();
			} else {
				$type .= " RENEW";
				$history{'concept'} .= " $old_file_to_new_dbi_concept";
			}
	}

	# ���t�@�C����W�J����
	foreach(@file){

		my(%data);

		# �t�@�C���̍s�𕪉�
		chomp;
	my($thread_last_restime2,$thread_lasthandle2);
	my($thread_keylevel2);
		(undef,$data{'concept'},$data{'subject'},$data{'thread_number'},$data{'res_number_histories'},$data{'bbs_kind'},$data{'bbs_title'},undef,$data{'my_regist_time'},$data{'server_domain'},undef,$data{'handle'},undef,$data{'deleted_resnumber_histories'},undef,undef,undef,undef,undef,$data{'last_read_thread_time'},$data{'last_read_res_number'}) = split(/<>/);
	push @{$history{'res_line_data'}} , \%data;

		# �Ǐ���
		my($viewkey2,@resnumber_histories2,$not_view_line,$escape_index_flag,$escape_flag,$myres_count2,$relay_type2,$already_read_flag2,$unread_res_number2);

		# ���E���h�J�E���^
		$i++;

			# �������񂾃X���b�h �ԍ�/ ���X�ԏ�񂾂���z��ɂ��Ē��o���� ( �Ǘ��p => ���e��������̈�č폜���ɗ��p )
			if($type{'GetAllThreadAndRes'}){
					foreach my $res_number (split(/\s/,$data{'res_number_histories'})){
						$history{'AllRegist'}{$data{'bbs_kind'}}{$data{'thread_number'}}{$res_number} = 1;
					}
			}

			# �K�{�f�[�^���Ȃ��ꍇ�A���Ă���ꍇ�A�ǂ̏����ł��G�X�P�[�v����
			if($data{'bbs_kind'} eq "" || $data{'bbs_title'} eq "" || $data{'thread_number'} eq ""){ next; }
			if($data{'thread_number'} =~ /\D/ || $data{'bbs_kind'} =~ /\W/){ next; }

			# �����̃��X�Ԃ𐮌`
			my @deleted_resnumber_histories2 = split(/\s/,$data{'deleted_resnumber_histories'});
			foreach(split(/\s|,/,$data{'res_number_histories'})){
				push(@resnumber_histories2,$_);
			}
		my($res_number2) = $resnumber_histories2[0];

			# ���X���e�񐔂��`
			$myres_count2 = @resnumber_histories2 + @deleted_resnumber_histories2;

		# ���g�b�v�f�[�^�̃n�b�V���� - �C���f�b�N�X�̂P�s�ڂ����͎擾���� (A-1)
		if($i == 1 && $type =~ /(TOPDATA|Get-hash-only)/){
			$history{'lastsub'} = $data{'subject'};
			$history{'lastmoto'} = $data{'bbs_kind'};
			$history{'lastno'} = $data{'thread_number'};
			$history{'lastres'} = $res_number2;

				# �t�@�C���n���h������āA���̂܂܃��^�[������
				if($type =~ /TOPDATA|Get-hash-only/){
					close($filehandle1);
					return(%history);
				}

		}

			# �ЂƂ̌f�����ŁA�ŋ߃��X���������ǂ����𒲍�
			if($type =~ /Get-lastres-time/){
					if($res_number2 >= 1 && $data{'bbs_kind'} eq $search_moto && $data{'concept'} !~ /Self-thread/){
						$lastrestime_bbs = $data{'my_regist_time'};
						last;
					}
			}

			# �B���s�̏ꍇ ( �G�X�P�[�v�����獢�鏈���ɒ��ӁB���̈ʒu���ԈႦ�Ȃ��悤�� )
			if($data{'concept'} =~ /Hidden/ && $type !~ /Admin/){ $escape_flag = 1; }
			if($data{'server_domain'} eq ""){ $escape_flag = 1; }

			# �ŋߓ��e�����f���̈ꗗ���擾����
			if($type =~ /BBS-list/ && !$bbslist{$data{'bbs_kind'}} && !$escape_flag){
				push(@bbslist,"$data{'bbs_kind'}=$data{'bbs_title'}");
				$bbslist{$data{'bbs_kind'}} = 1;
			}

			# ���X���b�h���擾��
			if($RENEW_STATUS_FLAG){

					# ���X���b�h���擾���Ȃ��ꍇ ( elsif else ���q����悤�� )
					if($escape_flag){

					# ���X���b�h���擾����ꍇ
					} elsif($thread_status_from_dbi && Mebius::Switch::dbi_new_res_history()){

							# DBI �ɂ��V�����擾���菈��
							my $dbi_data = $thread_status_from_dbi->{$data{'bbs_kind'}}->{$data{'thread_number'}};

							# �����R�[�h�����݂���ꍇ
							if(exists $thread_status_from_dbi->{$data{'bbs_kind'}}->{$data{'thread_number'}}){

									$hit_get_thread++;

									$data{'last_res_number'} = $dbi_data->{'res_number'};
									$thread_last_restime2 = $data{'last_res_time'} = $dbi_data->{'regist_time'};

									$data{'subject_dbi'} = $dbi_data->{'subject'};
									$data{'last_handle_dbi'} = $dbi_data->{'handle'};

									($data{'subject'}) = shift_jis_return($dbi_data->{'subject'});
									($thread_lasthandle2) = shift_jis_return($dbi_data->{'handle'});

								# �����R�[�h�����݂��Ȃ��ꍇ�A�����I�Ƀf�[�^�x�[�X�ɒǉ�����
								} elsif(rand(1) < 1) {

									my($thread) = Mebius::BBS::thread_state($data{'thread_number'},$data{'bbs_kind'});
									($data{'subject_dbi'}) = utf8_return($thread->{'subject'});
									($data{'last_handle_dbi'}) = utf8_return($thread->{'lasthandle'});

										# �����Ƀf�[�^�x�[�X�ɓo�^
										if($thread->{'f'}){
											#Mebius::BBS::ThreadStatus->update_table({ update => { bbs_kind => $data{'bbs_kind'} , thread_number => $data{'thread_number'} , res_number => $thread->{'res'} , regist_time => $thread->{'lastrestime'} , subject => $data{'subject_dbi'} , handle => $data{'last_handle_dbi'} } });
											my $thread_utf8 = hash_to_utf8($thread);
											Mebius::BBS::ThreadStatus->update_table($thread_utf8);
										}

										# ����̃Z�b�V�����ɂ����Ƀf�[�^��
										$data{'last_res_number'} = $thread->{'res'};
										$thread_last_restime2 = $data{'last_res_time'} = $thread->{'lastrestime'};
										$data{'subject'} =  $thread->{'subject'};
										$thread_lasthandle2 = $thread->{'lasthandle'}; 
										$data{'last_handle'} = $thread_lasthandle2;

								}

						}
			}

			# �����ǊǗ� (D-1)
			{
					# ���e�������{����Ԃɂ��� (E-1)
					if($use->{'ReadThread'}){

							if($q->param('moto') eq $data{'bbs_kind'} && $q->param('no') eq $data{'thread_number'}){
								$data{'last_read_thread_time'} = time;
								$read_thread_hit_flag = 1;
									if($use->{'read_thread_res_number'} =~ /^[0-9]+$/){
										$data{'last_read_res_number'} = $use->{'read_thread_res_number'};
									}
							}
					}

					# ���ǔ��� (E-2)
					if($data{'last_read_res_number'} >= $data{'last_res_number'} || $resnumber_histories2[0] == $data{'last_res_number'}){
						$already_read_flag2 = $data{'already_read_flag'} = 1;
					} else {
							if($resnumber_histories2[0] > $data{'last_read_res_number'}){
								$unread_res_number2 = $data{'last_res_number'} - $resnumber_histories2[0];
							} else {
								$unread_res_number2 = $data{'last_res_number'} - $data{'last_read_res_number'};
							}
							if($unread_res_number2 < 0){ $unread_res_number2 = 0; }
						$data{'unread_res_num'} = $unread_res_number2;
					}

			}

			# ���g�s�b�N�X��z��ɒǉ� ( D02 )
			if($type =~ /TOPICS/ && !$escape_flag){
				$got_topics{"$data{'bbs_kind'}-$data{'thread_number'}"} = 1;
				$i_topics++;
				
					# �����ˁI�t�@�C���̏ꍇ
					#if($type{'Crap-file'}){ $relay_type2 .= qq( Crap); }
					#elsif($type{'Check-file'}){ $relay_type2 .= qq( Check); }

					$data{'history_type'} = $history{'history_type'};
					push(@topics, \%data);
			}

			# ���h�ȈՁh���e�������擾��
			if($type =~ /ONELINE/ && $hit_one < $maxview_one && !$escape_flag){
				my($newmark_oneline,$class);
				$hit_one++;
					if($thread_last_restime2 > $data{'my_regist_time'} && $thread_lasthandle2){
						$newmark_oneline = qq( ( <a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}.html#S$data{'last_res_number'}"$class>$thread_lasthandle2</a> ) );
					}

					# �g�є�
					if($my_use_device->{'mobile_flag'}){
						$one_line .= qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}.html#S$res_number2">$data{'subject'}</a>$newmark_oneline<br />);
					}

					# PC��
					else{
							if($hit_one >= 2){ $one_line .= qq( / ); }
						$one_line .= qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}.html#S$res_number2">$data{'subject'}</a>$newmark_oneline);
					}
			}

			# ���t�H���[��������f���̎�ނ��擾��
			if($type =~ /FOLLOW/ && $hit_follow < $maxget_follow && !$escape_flag){
				$hit_follow++;
				push(@follow_bbs,$data{'bbs_kind'});
			}

			# ���C���f�b�N�X���擾�p�̏���
			if($type =~ /INDEX/){

				# �C���f�b�N�X�p�̃��E���h�J�E���^
				$i_index++;

					# �����ȊO�ɂ͌����Ȃ��f����/�L��
					if($data{'concept'} =~ /(secret|Deleted-thread)/ || ($res_number2 eq "" && $type =~ /Res-file/) || $data{'bbs_kind'} =~ /(^sc)/){ #  || $thread_keylevel2 < 0
							# ��\���s�ł��A��t���ŕ\������ꍇ
							if($myhistory_flag || $type =~ /Admin/){ $viewkey2 .= qq( <span class="alert">[ ��\\�� ]</span>); }
							else{ $escape_index_flag = 1; }
					}

			}

			# ���C���f�b�N�X���擾��
			if($type =~ /INDEX/ && $hit_index < $maxview_index && !$escape_flag && !$escape_index_flag && !Mebius::Fillter::heavy_fillter(utf8_return($data{'subject'}))){

				# �Ǐ���
				my($resmark,$view_lasthandle,$lastminute,$view_mylasttime,$view_mylasttime_link,$mark2,$backurl_encoded);
				my($delete_res_reason);

					# �L�[��������ꍇ
					if($my_account->{'admin_flag'} >= 1 || $type =~ /Admin/){ $viewkey2 .= qq( $data{'concept'}); }

					# �Ǘ����[�h�ł̖߂����G���R�[�h
					if($type =~ /Admin/){
						$backurl_encoded = Mebius::Encode(undef,"$basic_init->{'main_url'}?$main::postbuf#HISTORY");
							if($param->{'comment_control'}){ $delete_res_reason .= qq(&amp;comment_control=).e($param->{'comment_control'}); }
							if($param->{'handle'}){ $delete_res_reason .= qq(&amp;handle=).e($param->{'handle'}); }
					}

					# �������쐬�����L��
					if($data{'concept'} =~ /Self-thread/){ $mark2 .= qq( <span style="color:#f00;">[ �쐬�� ]</span>); }

					# �M���̈���
					if($data{'concept'} =~ /Handle-deleted/){ $data{'handle'} = qq(���e); }

				# �J�E���g
				$hit_index++;

					# �����̓��e�����i�����O�`�����O���j���`
					if($data{'my_regist_time'}){
						($view_mylasttime) = Mebius::SplitTime("Get-top-unit Blank-view Plus-text-�O",time - $data{'my_regist_time'});
					}

				# ���y�[�W�ڂւ̃����N��
				my($plustype_page_number);
					if($type =~ /Admin/){ $plustype_page_number .= qq( Admin-view);  }
				my($page_number_lasttime) = Mebius::Page::NowPagenumber("$plustype_page_number",$res_number2,$data{'last_res_number'},$per_page,$per_first_page);

					# �����N�ݒ� 
					if($type =~ /Admin/){
						$view_mylasttime_link = qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}$page_number_lasttime&amp;backurl=$backurl_encoded#S$res_number2" class="mylasttime">$view_mylasttime</a>); 
					}
					else{
						#$view_mylasttime_link = qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}$page_number_lasttime.html#S$res_number2" class="mylasttime">$view_mylasttime</a>);
						$view_mylasttime_link = qq($view_mylasttime);
					}

					# �����ˁI�t�@�C���̏ꍇ
					if($type{'Crap-file'} || $type{'Check-file'}){
						$view_mylasttime_link = $view_mylasttime;
					}


				# �M�������N�̐��`
				my $res_number_view = "($res_number2)" if($my_use_device->{'narrow_flag'} && defined $res_number2);

					# ���ŋ߂̍X�V - ���J���� ( �M�������N )
					if($type =~ /Open-view/){

						my($page_number_open_view) = Mebius::Page::NowPagenumber("$plustype_page_number",$res_number2,undef,$per_page);

							# �M�����Ȃ��ꍇ�͑��
							if($data{'handle'} eq ""){ $data{'handle'} = "���e"; }

							# �Ǘ��p
							if($type =~ /Admin/){
								$view_lasthandle = qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}$page_number_open_view&amp;backurl=$backurl_encoded#S$res_number2">$data{'handle'}$res_number_view </a>);
							}
							# ��ʗp
							else{
								$view_lasthandle = qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}$page_number_open_view.html#S$res_number2">$data{'handle'}$res_number_view </a>);
							}

							# �{�l�����e�����������`
							if($data{'my_regist_time'}){
								($lastminute) = Mebius::SplitTime("Get-top-unit Blank-view Plus-text-�O Color-view-else",time - $data{'my_regist_time'});
							}
					}

					# ���ŋ߂̍X�V - ����J����
					else{
							# �ŏI���e�҂̕M��
							if($thread_lasthandle2){
								$view_lasthandle = qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}.html#S$data{'last_res_number'}">$thread_lasthandle2$res_number_view </a>);
							}
							# �ŐV���X�̌o�ߎ��Ԃ�\��
							if($thread_last_restime2){
								($lastminute) = Mebius::SplitTime("Get-top-unit Color-view-else Plus-text-�O",time - $thread_last_restime2);
							}
					}

				# �M�������̐��`
				if($view_lasthandle){
						if($my_use_device->{'wide_flag'}){
								# ���ǐ��̕\��
								if($unread_res_number2 >= 1){
									$view_lasthandle = "( $view_lasthandle <strong class=\"new margin\">$unread_res_number2</strong> )";
								} else {
									$view_lasthandle = "( $view_lasthandle )";
								}

						}
				}

					# ���\�����e ( ���o�C�� )
					#if($my_use_device->{'type'} eq "Mobile"){
					if($my_use_device->{'narrow_flag'}){

						my($div_style,$def_back);
							if($hit_index % 2 == 0){ $div_style = qq( style="background:#eee;"); $def_back = " def_back"; }

							if($my_use_device->{'smart_flag'}){
								$index_line .= qq(<div class="els$def_back">);
							} else {
								$index_line .= qq(<div$div_style>);
							}

							# �R���g���[���p
							if($type =~ /Mypage-view/){
								$index_line .= qq(<input type="checkbox" name="history-$data{'bbs_kind'}-$data{'thread_number'}" value="delete"$main::xclose> \n);
							}

						$index_line .= qq(<a href="/_$data{'bbs_kind'}/$data{'thread_number'}.html">$data{'subject'}</a>);

							# �f�������N
							if($my_use_device->{'mobile_flag'}){
								$index_line .= qq(<div style="text-align:right;">);
							} else {
								$index_line .= qq(<div class="right">);
							}
						$index_line .= qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/">$data{'bbs_title'}</a>);
						$index_line .= qq(</div>);

							# �M�������N
							if($my_use_device->{'mobile_flag'}){
								$index_line .= qq(<div style="text-align:right;">);
							} else {
								$index_line .= qq(<div class="right">);
							}
						$index_line .= qq($lastminute - );
						$index_line .= qq($view_lasthandle);
						$index_line .= qq(</div>);


	
						# �S�̂̕��^�O
						$index_line .= qq(</div>\n);

					}

					# ���\�����e ( �f�X�N�g�b�v )
					else{
						$index_line .= qq(<tr>);
						$index_line .= qq(<td>);

							# ���L���ւ̃����N
							if($type =~ /Admin/){
								$index_line .= qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}&amp;backurl=$backurl_encoded">$data{'subject'}</a>);
							}
							else{
								$index_line .= qq(<a href="/_$data{'bbs_kind'}/$data{'thread_number'}.html">$data{'subject'}</a>);
							}

						$index_line .= qq($viewkey2);
						$index_line .= qq($mark2);
						$index_line .= qq(</td>);

						# ���ŏI���X�������M��
						$index_line .= qq(<td>);
						$index_line .= qq($view_lasthandle);
						$index_line .= qq(</td>);


						# �� 
						$index_line .= qq(<td class="right">$lastminute</td>);

							# ���f���ւ̃����N
							if($type =~ /Admin/){
								$index_line .= qq(<td><a href="${main::jak_url}$data{'bbs_kind'}.cgi">$data{'bbs_title'}</a></td>);
							}
							else{
								$index_line .= qq(<td><a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/">$data{'bbs_title'}</a></td>);
							}

				
							# ���X�Ԃ�W�J
							my @all_res_numbers = sort { $b <=> $a } (@resnumber_histories2,@deleted_resnumber_histories2);
							my @res_numbers = sort { $b <=> $a } @resnumber_histories2;
							my @deleted_res_numbers = sort { $b <=> $a } @deleted_resnumber_histories2;

							my $all_res_numbers = join "," , @all_res_numbers;
							my $res_numbers = join "," , @res_numbers;
							my $deleted_res_numbers = join "," , @deleted_res_numbers;

							my $all_res_count = @all_res_numbers;
							my $res_count = @res_numbers;
							my $deleted_res_count = @deleted_res_numbers;

							# ����J���� - �����̓��e����
							if($type !~ /Open-view/){
								#$index_line .= qq(<td class="justy"><a href="/_$data{'bbs_kind'}/$data{'thread_number'}.html-$all_res_numbers" rel="nofollow">${myres_count2}��</a></td>);
								$index_line .= qq(<td class="justy">$view_mylasttime_link</td>);
							}

							# ���J���� - ���e��
							{
									# ���Ǘ��p
									if($type =~ /Admin/){

										$index_line .= qq(<td class="justy">);
											
										#$index_line .= qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}&amp;No=$res_numbers$delete_res_reason#RESNUMBER">${res_count}��</a>\n); 
										#$index_line .= qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}&amp;No=$deleted_res_numbers$delete_res_reason#RESNUMBER">${deleted_res_count}��</a>\n); 
										$index_line .= qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}&amp;No=$all_res_numbers$delete_res_reason#RESNUMBER">${all_res_count}��</a>\n); 

										#&amp;&view_only_this_number=1&amp;backurl=$backurl_encoded
										$index_line .= " ( " . (@resnumber_histories2). "�� )";
										$index_line .= qq(</td>);
									}
									# ��ʗp
									else{
											if(Mebius::Device::bot_judge()){
												$index_line .= qq(<td>${myres_count2}��</td>);
											} else {
												$index_line .= qq(<td class="justy"><a href="/_$data{'bbs_kind'}/$data{'thread_number'}.html-$all_res_numbers" rel="nofollow">${myres_count2}��</a></td>);
											}
									}
							}


							# �R���g���[���p
							if($type =~ /Mypage-view/){
								$index_line .= qq(<td><input type="checkbox" name="history-$data{'bbs_kind'}-$data{'thread_number'}" value="delete"></td>\n);
							}


						$index_line .= qq(</tr>\n);
					}
			}

			# ���e������S�č폜����
			if($type =~ /UNLINK/ && $data{'concept'} !~ /Hidden/){
				$data{'concept'} .= qq( Hidden);
			}

			# ���e�������w��폜���� (�����I���\)
			if($type =~ /Control-history/){
					foreach(split(/&/,$main::postbuf)){
						my($key,$value) = split(/=/,$_);
							if($key =~ /^\Qhistory-${data{'bbs_kind'}}-${data{'thread_number'}}\E$/){
									if($value eq "delete" && $data{'concept'} !~ /Hidden/){ $data{'concept'} .= qq( Hidden); }
							}
					}
			}


			# ���֘A�L���o�^�̂��߂̏�����
			if($type =~ /KRCHAIN/ && !$escape_flag){

					# �d�������L���̓G�X�P�[�v����
					if($data{'bbs_kind'} eq $prealmoto && $data{'thread_number'} eq $pi_postnumber){ next; }

					# �e��l�N�X�g
					if($data{'concept'} =~ /(nokr|secret)/){ next; }
					elsif($data{'bbs_kind'} =~ /(^sub|^sc)/){ next; }
					elsif($prealmoto == $data{'bbs_kind'} && $data{'thread_number'} == $pi_postnumber){ next; }
					else{ @krchain_line = ($data{'thread_number'},$data{'bbs_kind'},$data{'subject'},$data{'server_domain'}); last; }

			}

			# ���t�@�C���X�V�p ( While �̓r���� $type .= " RENEW" ���w�肵���肷��ƁA����ȑO�̍s�͏����Ă��܂��\��������̂Œ��� )
			my $next_flag_closure; # �N���[�W���̒��� next; ���g���ƕςɂȂ�̂ŁA�t���O�𗘗p
			{

					# �����L���̓G�X�P�[�v
					if($type =~ /(REGIST|New-crap|New-check)/ && $data{'bbs_kind'} eq $prealmoto && $data{'thread_number'} eq $pi_postnumber){

						# �ꕪ�̏��͊o���Ă����āA���ƂŐV�����s�ɔ��f����
						$keep_res_number_histories = $data{'res_number_histories'};
							if($data{'concept'} =~ /Self-thread/){ push(@newkey2,"Self-thread"); }
							$pdeleted_resnumber_histories = $data{'deleted_resnumber_histories'};

						$next_flag_closure = 1;

					}

					# ���X�̍폜 ( �P�L��������̓��e�񐔂̌��Z )
					if($type =~ /Delete-res/ && "$delete_realmoto-$delete_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
						my(@renew);
							foreach(@resnumber_histories2){
									if($_ eq $delete_res_number){ push(@deleted_resnumber_histories2,$_); }
									else{ push(@renew,$_); }
							}
						$data{'res_number_histories'} = "@renew";
						$myres_count2 = @renew;
						@deleted_resnumber_histories2 = sort {$b <=> $a} (@deleted_resnumber_histories2);
						$data{'deleted_resnumber_histories'} = "@deleted_resnumber_histories2";
					}

					# �s ( �L���P�� ) �̍폜
					if($type =~ /Delete-thread/ && $data{'concept'} !~ /Deleted-thread/){
							if("$delete_realmoto-$delete_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								$data{'concept'} .= qq( Deleted-thread);
							}
					}

					# �M���̍폜
					if($type =~ /Delete-handle/ && $data{'concept'} !~ /(Handle-deleted)/){
							if("$delete_realmoto-$delete_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								$data{'concept'} .= qq( Handle-deleted);
							}
					}

					# �s( �L���P�� ) �̕���
					if($type =~ /Repair-res/){
							if("$repair_realmoto-$repair_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								my(@renew);
									foreach(@deleted_resnumber_histories2){
											if($_ eq $repair_res_number){ push(@resnumber_histories2,$_); }
											else{ push(@renew,$_); }
									}
								$data{'deleted_resnumber_histories'} = "@renew";
								@resnumber_histories2 = sort {$b <=> $a} (@resnumber_histories2);
								$data{'res_number_histories'} = "@resnumber_histories2";
								$myres_count2 = $data{'res_number_histories'};
							}
					}

					# �s�̕���
					if($type =~ /Repair-thread/ && $data{'concept'} =~ /Deleted-thread/){
							if("$repair_realmoto-$repair_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								$data{'concept'} =~ s/(\s?)Deleted-thread//g;
							}
					}

					# �M���̕���
					if($type =~ /Repair-handle/ && $data{'concept'} =~ /Handle-deleted/){
							if("$repair_realmoto-$repair_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								$data{'concept'} =~ s/(\s?)Handle-deleted//g;
							}
					}

					# �S�L�������t�b�N
					if($data{'concept'} !~ /Deleted-thread/ && $myres_count2 >= 1){ $tall_thread_buffer++; }

			}
			if($next_flag_closure){ next; }

			# �� �X�V�s�̒ǉ� ( ���ۂ̓t�@�C���X�V���Ȃ��ꍇ�ł��A�t�@�C��������\�h���邽�߂ɁA�ϐ��Ƃ��Ēǉ����Ă��� )
			# �����X���b�h�̏d�������
			if($renew_line_redun{$data{'server_domain'}}{$data{'bbs_kind'}}{$data{'thread_number'}}){
				0;
			# �X�V�s��ǉ�
			} elsif($hit_renew <= $max_line){

				$hit_renew++;
push(@renew_line,"<>$data{'concept'}<>$data{'subject'}<>$data{'thread_number'}<>$data{'res_number_histories'}<>$data{'bbs_kind'}<>$data{'bbs_title'}<><>$data{'my_regist_time'}<>$data{'server_domain'}<><>$data{'handle'}<><>$data{'deleted_resnumber_histories'}<>$thread_last_restime2<>$data{'last_res_number'}<>$thread_lasthandle2<>$thread_keylevel2<><>$data{'last_read_thread_time'}<>$data{'last_read_res_number'}<>\n");
				$renew_line_redun{$data{'server_domain'}}{$data{'bbs_kind'}}{$data{'thread_number'}} = 1;
			}

	# While �����I���
	}


	# �X�V���f
	if($use->{'ReadThread'} && $read_thread_hit_flag){
		$type .= qq( RENEW);
	}


	# �� �f�[�^�L�^
	if($type =~ /RENEW/ && $type =~ /My-file/){

		# �e������擾
		my($myaddress) = Mebius::my_address();

		# �Ǐ���
		my(@tcnumbers,@thosts,@taccounts,@tagents,@ttrips,@temails,@tnames,@tencids);
		my($i_tcnumbers,$i_thosts,$i_taccounts,$i_tagents,$i_emails,$i_trips,$i_names,$i_encids);

			# �Ǘ��ԍ�������W�J
			if($main::cnumber){
				my($already_flag);
					foreach(split(/\s/,$tcnumbers)){
						$i_tcnumbers++;
							if($i_tcnumbers >= 10){ next; }
							if($_ eq $main::cnumber){ $already_flag = 1; }
						push(@tcnumbers,$_);
					}
					if(!$already_flag){ unshift(@tcnumbers,$main::cnumber); }
				$tcnumbers = qq(@tcnumbers);
			}

			# ���[�U�[�G�[�W�F���g������W�J
			if($main::agent){
				my($already_flag);
				my($agent_encoded) = Mebius::Encode(undef,$main::agent);
					foreach(split(/\s/,$tagents)){
						$i_tagents++;
							if($i_tagents >= 10){ next; }
							if($_ eq $agent_encoded){ $already_flag = 1; }
						push(@tagents,$_);
					}
					if(!$already_flag){ unshift(@tagents,$agent_encoded); }
				$tagents = qq(@tagents);
			}

			# �z�X�g��������W�J
			if($main::host){
				my($already_flag);
					foreach(split(/\s/,$thosts)){
						$i_thosts++;
							if($i_thosts >= 10){ next; }
							if($_ eq $main::host){ $already_flag = 1; }
						push(@thosts,$_);
					}
					if(!$already_flag){ unshift(@thosts,$main::host); }
				$thosts = qq(@thosts);
			}

			# �A�J�E���g��������W�J
			if($my_account->{'id'}){
				my($already_flag);
				foreach(split(/\s/,$taccounts)){
					$i_taccounts++;
						if($i_taccounts >= 10){ next; }
						if($_ eq $my_account->{'id'}){ $already_flag = 1; }
					push(@taccounts,$_);
				}
				if(!$already_flag){ unshift(@taccounts,$my_account->{'id'}); }
				$taccounts = qq(@taccounts);
			}

			# ���[���A�h���X��W�J
			if($myaddress->{'address'}){
				my($already_flag);
				foreach(split(/\s/,$temails)){
					$i_emails++;
						if($i_emails >= 10){ next; }
						if($_ eq $myaddress->{'address'}){ $already_flag = 1; }
					push(@temails,$_);
				}
				if(!$already_flag){ unshift(@temails,$myaddress->{'address'}); }
				$temails = qq(@temails);
			}

			# �M����W�J
			if($main::i_name && $main::crireki ne "off"){
				my($already_flag);
				my($name_encoded) = Mebius::Encode(undef,$main::i_name);
				foreach(split(/\s/,$tnames)){
					$i_names++;
						if($i_names >= 10){ next; }
						if($_ eq $name_encoded){ $already_flag = 1; }
					push(@tnames,$_);
				}
				if(!$already_flag){ unshift(@tnames,$name_encoded); }
				$tnames = qq(@tnames);
			}

			# �g���b�v��W�J
			if($main::enctrip){
				my($already_flag);
				foreach(split(/\s/,$ttrips)){
					$i_trips++;
						if($i_trips >= 10){ next; }
						if($_ eq $main::enctrip){ $already_flag = 1; }
					push(@ttrips,$_);
				}
				if(!$already_flag){ unshift(@ttrips,$main::enctrip); }
				$ttrips = qq(@ttrips);
			}

			# ID��W�J
			if($main::encid){
				my($already_flag);
				foreach(split(/\s/,$tencids)){
					$i_encids++;
						if($i_encids >= 10){ next; }
						if($_ eq $main::encid){ $already_flag = 1; }
					push(@tencids,$_);
				}
				if(!$already_flag){ unshift(@tencids,$main::encid); }
				$tencids = qq(@tencids);
			}

	}

	# ���t�@�C�����X�V
	if($type =~ /RENEW/){

			# �����e�L�^���̏���
			if($type =~ /REGIST/){

					# �V�����s�́y���L�[�z���`
					if($secret_mode || $concept =~ /NOT-KR/ || $subtopic_mode){ push(@newkey2,"nokr"); }
					if($secret_mode){ push(@newkey2,"secret"); }
					if($pi_resnumber eq "0"){ push(@newkey2,"Self-thread"); }
					if($type =~ /New-line-hidden/){ push(@newkey2,"Hidden"); }

				$newkey = 1;

				# �{���̒����𔻒�
				my($comment) = ($pcomment);
				$comment =~ s/( |�@|<br>)//g;
				$plength = int(length($pcomment) / 2);

					# �������֘A
					if(!$history{'last_regist_time_per_hour'} || time > $history{'last_regist_time_per_hour'} + (1*60*60)){
						$history{'last_regist_time_per_hour'} = time;
					}
				$history{'all_length_per'} += $plength;

					# �V�������X��
					if(defined($keep_res_number_histories)){ $new_resnumber_histories = join " " , ($pi_resnumber,$keep_res_number_histories); }
					else{ $new_resnumber_histories = $pi_resnumber; }

				# �V�����ǉ�����s
				$tall_thread_buffer++;

				# �g�b�v�f�[�^�ɑ��
				$tlastcomment = $pcomment;
				$history{'regist_count'}++;
				$history{'regist_count_per'}++;
			}


			# ���V�����ǉ�����s
			if($type =~ /(REGIST|New-crap|New-check)/){

				# ���L�����擾
				my(%thread) = Mebius::BBS::thread({},$prealmoto,$pi_postnumber);

				# �ǉ��s
unshift(@renew_line,"$newkey<>@newkey2<>$thread{'subject'}<>$pi_postnumber<>$new_resnumber_histories<>$prealmoto<>$ptitle<>$main::date<>$time<>$pserver_domain<><>$phandle<>$pencid<>$pdeleted_resnumber_histories<>$thread{'lastrestime'}<>$thread{'res'}<>$thread{'lasthandle'}<>$thread{'keylevel'}<><>$time<>\n");



			}

			# �����e�������Z�b�g���́A�g�b�v�f�[�^�̏���
			if($type =~ /UNLINK/){
				$tnames = undef;
			}

			# ���A�J�E���g�̐V�K�쐬
			if($type =~ /Make-account/){

					# �A���쐬����
					if($history{'make_account_blocktime'} < $renew{'make_account_blocktime'}){
						$history{'make_account_blocktime'} = $renew{'make_account_blocktime'};
					}

					# �A�J�E���g�쐬������ǉ�
					if($history{'make_accounts'}){ $history{'make_accounts'} = qq($renew{'plus_make_accounts'} $history{'make_accounts'}); }
					else{ $history{'make_accounts'} .= $renew{'plus_make_accounts'}; }

			}

			# ���n�b�V����đ���
			if(%renew){
				my($renew) = Mebius::Hash::control(\%history,\%renew);
				($renew) = Mebius::format_data_for_file($renew);
				%history = %$renew;
			}


			# ���S�L�������L�^
			if(defined($tall_thread_buffer)){ $tall_thread = $tall_thread_buffer; }

			# ���g�b�v�f�[�^��ύX
			if($type =~ /(REGIST|New-crap|New-check)/){
				$taddr = $ENV{'REMOTE_ADDR'};
			}

			# �������̃f�[�^�̏ꍇ
			if($type =~ /My-file/){
				$history{'lasttime'} = time;
			}

		# �g�b�v�f�[�^��ǉ�
	unshift(@renew_line,"$history{'key'}<>$history{'lasttime'}<>$history{'first_time'}<>$history{'renew_time'}<>$tunique<>$pid<><><><><>$taddr<><><>$tlastcomment<>$pcharge_ressecond<>$pcharge_postsecond<>$tcnumbers<>$thosts<>$taccounts<>$tagents<>$temails<>$tnames<>$ttrips<>$tlast_deadlink_checktime<>$history{'regist_count'}<>$tencids<>$tall_thread<>$history{'make_account_blocktime'}<>$history{'last_renew_status_time'}<>$history{'last_regist_time_per_hour'}<>$history{'all_length_per'}<>$history{'make_accounts'}<>$history{'regist_count_per'}<>$history{'concept'}<>\n");

		# �X�V
		seek($filehandle1,0,0);
		truncate($filehandle1,tell($filehandle1));
		print $filehandle1 @renew_line;

	}

close($filehandle1);

	# �p�[�~�b�V�����ύX
	if($type =~ /RENEW/){ Mebius::Chmod(undef,$history_file); }

		# �`�F�b�N�����̎擾�A�ǉ�
		if($type =~ /TOPICS/){
				if($type =~ /TOPICS-get-only/){ return(@topics); }
			my(@check_topics) = main::get_reshistory("TOPICS-get-only Check-file My-file Allow-renew-status",undef,$use,%got_topics);
			push(@topics,@check_topics);
		}

		# �g�s�b�N�X�̐��`
		if($type =~ /TOPICS/ && @topics){
			($topics_line) = Mebius::History->topics($maxview_topics,@topics);
			$topics_line;
		}

		# �P�s�����̐��`
		if($type =~ /ONELINE/ && $one_line){
				if($my_use_device->{'type'} eq "Mobile"){ }
				else{
						if($one_line){ $one_line .= qq( / <a href="$basic_init->{'main_url'}?mode=my#RESHISTORY" class="green">�c����������</a>); }
					$one_line .= qq( / <a href="$basic_init->{'main_url'}?mode=my#EDIT">�c�ݒ�</a>);
					$one_line = qq(<span class="one_line"><strong>�����F</strong> $one_line</span>);
				}
		}

	# �C���f�b�N�X�̐��`
		if($type =~ /INDEX/ && $type !~ /OLD/ && $index_line){
			my($flowlink,$postbuf_enc) = ("",$postbuf);
				if($i_index > $maxview_index){ $index_flow = 1;	}

				# �g�є�
				#if($my_use_device->{'type'} eq "Mobile"){
				if($my_use_device->{'narrow_flag'}){
					$index_line = qq(<div style="$main::ktextalign_center_in">$index_line</div>$flowlink\n);
				}

				# �f�X�N�g�b�v��
				else{
						# ���J����
						if($type =~ /Open-view/){
							$index_line = qq(<table summary="���e����" class="history_table width100">\n<tr><th>�L��</th><th colspan="2">���e</th><th>�f����</th><th class="justy">���e��</th></tr>\n$index_line</table>$flowlink);
						}

						# ����J���� - �����ˁI
						elsif($type =~ /Crap-file|Check-file/){
							$index_line = qq(<table summary="���e����" class="history_table width100">\n<tr><th>�L��</th><th colspan="2">���e</th><th>�f����</th><th class="justy">����</th></tr>\n$index_line</table>$flowlink);
						}

						# ����J���� - ���X���e
						else{
							$index_line = qq(<table summary="���e����" class="history_table width100">\n<tr><th>�L��</th><th colspan="2">�X�V</th><th>�f����</th><th class="justy">�ŏI���e</th><th class="justy">���e��</th><th>��</th></tr>\n$index_line</table>$flowlink);
						}


				}

				# ����J����
				if($type =~ /Mypage-view/){
					$return_index_line .= qq(<form action="./?mode=my" method="post" utn="utn"><div>\n);
					$return_index_line .= qq(<input type="hidden" name="mode" value="my"$main::xclose>\n);
					$return_index_line .= qq(<input type="hidden" name="type" value="control_history"$main::xclose>\n);
						if($type{'Crap-file'}){ $return_index_line .= qq(<input type="hidden" name="target_file" value="crap"$main::xclose>\n); }
						elsif($type{'Check-file'}){ $return_index_line .= qq(<input type="hidden" name="target_file" value="check"$main::xclose>\n); }
						else{ $return_index_line .= qq(<input type="hidden" name="target_file" value="res"$main::xclose>\n); }
					$return_index_line .= qq($main::backurl_input\n);
					$return_index_line .= qq($index_line\n);
					$return_index_line .= qq(<div style="text-align:right;"><input type="submit" name="history_delete" value="�������폜����"$main::xclose></div>\n);
					$return_index_line .= qq(</div></form>$flowlink\n);
				}
				else{
					$return_index_line = $index_line;
				}

		}

	# �e�탊�^�[��
	if($type{'GetReference'}){ return(\%history); }
	if($type =~ /TOPICS-get-only/){ return(@topics); }
	if($type =~ /Get-lastres-time/){ return($lastrestime_bbs); }
	if($type =~ /BBS-list/){ return(@bbslist); }
	if($type =~ /(TOPDATA|Get-hash-detail)/){
		if($type =~ /INDEX/){ $history{'index_line'} = $return_index_line; }
		return(%history);
	}
	if($type =~ /FOLLOW/){ return(@follow_bbs); }
	if($type =~ /(INDEX|ONELINE|NEWRES)/){ return($topics_line,$one_line,$return_index_line,$index_flow,%history); }
	if($type =~ /KRCHAIN/){ return(@krchain_line); }

return(%history);

}

#-----------------------------------------------------------
# DBI����X�V�����Q�b�g
#-----------------------------------------------------------
sub my_history_from_new_dbi{

my($file) = @_;
my $history = new Mebius::History;
my $dbi = new Mebius::DBI;
my(%self,$where,@where);

	foreach(@$file){

		chomp;
		my(undef,undef,undef,$thread_number2,undef,$bbs_kind2) = split(/<>/);

			if($thread_number2 =~ /\D/){ next; }
			if($bbs_kind2 =~ /\W/){ next; }

		push(@where,"(content_targetA='$bbs_kind2' AND content_targetB='$thread_number2')");
	}

	if(@where <= 0){ return(); }

my $where = join " OR " , @where;

my($data) = $history->fetchrow_main_table($where);

	foreach(@$data){
		$self{$_->{'bbs_kind'}}{$_->{'thread_number'}} = $_;
	}

\%self;

}
#-----------------------------------------------------------
# DBI����X�V�����Q�b�g
#-----------------------------------------------------------
sub thread_status_from_dbi{

my($file) = @_;
my($memory_table_name) = Mebius::BBS::ThreadStatus->main_memory_table_name();
#my($memory_table_name) = Mebius::BBS::ThreadStatus->main_table_name();

my(%self,$where,@where);

	foreach(@$file){

		chomp;
		my(undef,undef,undef,$thread_number2,undef,$bbs_kind2) = split(/<>/);

			if($thread_number2 =~ /\D/){ next; }
			if($bbs_kind2 =~ /\W/){ next; }

		push(@where,"unique_target='$bbs_kind2-$thread_number2'");
	}

	if(@where <= 0){ return(); }

my($where) = Mebius::join_array_with_mark(" OR ",@where);

my($data) = Mebius::DBI->fetchrow("SELECT * from `$memory_table_name` WHERE $where;");


	foreach(@$data){
		$self{$_->{'bbs_kind'}}{$_->{'thread_number'}} = $_;
	}

\%self;

}


package Mebius::BBS;
use Mebius::Export;

#-----------------------------------------------------------
# ���e�����̕\���y�[�W
#-----------------------------------------------------------
sub HistoryIndex{

# �錾
my($type,$filetype,$file) = @_;
my($h1_text,$guide_line,$plustype_getres_history,$line,$iframe_profile);
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();

# ���������N�؂�C�����u���b�N
$main::not_repair_url_flag = 1;
$main::css_text .= qq(
iframe.sns_profile{border-style:none;width:100%;height:5.5em;}
);

	if($my_use_device->{'smart_flag'}){
		$main::css_text .= qq(.body1{width:100%;});
	}

	# �g�єłւ̑Ή�
	if($my_use_device->{'type'} eq "mobile"){ main::kget_items(); }

	# Title��`
	$main::head_link2 = qq(&gt; ���e����);

	# �t�@�C����
	my $view_filename = $file;
	$view_filename =~ s/!/\//g;
	$view_filename =~ s/~/\./g;

	# �Ǘ��^�C�v
	if($type =~ /Admin-view/){
		$plustype_getres_history .= qq( Admin);
	}

	# �����^�C�v���`
	# �g���b�v
	if($filetype eq "trip"){
		$h1_text = "��$view_filename �̗���";
		$main::sub_title = qq(��$view_filename | �g���b�v);
		$main::head_link3 = qq(&gt; ��$view_filename);
		$guide_line = qq(��������ǉ��������Ȃ��ꍇ��<a href="${main::guide_url}%A5%C8%A5%EA%A5%C3%A5%D7">�g���b�v�K�C�h</a>���������������B);
		$plustype_getres_history .= qq( TRIP);
	}
	# ID
	elsif($filetype eq "id"){
		$h1_text = "��$view_filename �̗���";
		$main::sub_title = qq(��$view_filename | ID);
		$main::head_link3 = qq(&gt; ��$view_filename);
		$plustype_getres_history .= qq( ENCID);
		$guide_line = qq(��ID�͕K�������A����l���ł��邱�Ƃ�ۏ؂�����̂ł͂���܂���B���ɂ���Ă͑��̐l�Əd�Ȃ�ꍇ������܂��B);
		#<br>��ID�������L�^�������Ȃ��ꍇ�̓A�J�E���g�Ƀ��O�C��������ŁA���e�t�H�[���ŁuID�����v�̍��ڂ���`�F�b�N���O���Ă��������B
	}
	# �A�J�E���g
	elsif($filetype eq "account"){
		#$h1_text = qq(<a href=") . esc($basic_init->{'auth_url'}). esc($view_filename) . qq(/">). esc("\@$view_filename") . qq(</a> �̏��);
		$h1_text = qq(\@$view_filename �̗���);

		$main::sub_title = qq(\@$view_filename | �A�J�E���g);
		$main::head_link3 = qq(&gt; \@$view_filename);
		$plustype_getres_history .= qq( Open-account);
			if(1){
				$iframe_profile = qq(<h2><a href=") . esc("$basic_init->{'auth_url'}$view_filename/#PROF") . qq(">�v���t�B�[��</a></h2>);
				$iframe_profile .= qq(<iframe src=") . esc($basic_init->{'auth_url'}) . qq(?mode=sns_profile_iframe&amp;account=) . esc($view_filename) . qq(" class="sns_profile"></iframe>);
				$iframe_profile .= qq(<div><a href=") . esc("$basic_init->{'auth_url'}$view_filename/") . qq(">���A�J�E���g��S�ĕ\\������</a></div>);
			}
	}

	else{ main::error("���̕\\�����[�h�͑��݂��܂���B"); }

# CSS��`
$main::css_text .= qq(
div.navilinks{margin:1em 0em;}
table.history_table{margin:1em 0em;}
div.history_navigation{padding:0.5em 0.5em;background:#afa;}
);


# ���e�����t�@�C�����J��
my(%history) = main::get_reshistory("INDEX File-check-error Open-view Get-hash-detail $plustype_getres_history",$file);

	# �Ǘ��p�Ƀ����N�𐮌`
	if($type =~ /Admin-view/){
		($history{'index_line'}) = Mebius::Adfix("Url",$history{'index_line'});
	}

# ���L�^�����v�Z
my($first_date) = Mebius::Getdate(undef,$history{'first_time'}) if($history{'first_time'});
my($first_how_before) = shift_jis(Mebius::second_to_howlong({ GetLevel => "top" , ColorView => 1 , HowBefore => 1 } , time - $history{'first_time'})) if($history{'first_time'});

	# �����o�C���ł̕\��
	if($my_use_device->{'mobile_flag'}){
		$line .= qq(<div style="$main::kbackground_blue2_in$main::kborder_bottom_in">\n);
		$line .= qq(<h1$main::kstyle_h1>$h1_text</h1>\n);
		$line .= qq(</div>\n);
			if($iframe_profile){
				$line .= qq(<h2>���e����</h2>);
			}
		$line .= qq($history{'index_line'}\n);
		$line .= qq(<div style="$main::kbackground_green1_in$main::kborder_top_in$main::ktextalign_center_in">�f�[�^</div>\n);
		$line .= qq(<div>��ށF $history{'file_type_japanese'} / �L�^�J�n�F $first_how_before ( $first_date ) / ���e�񐔁F $history{'regist_count'}��</div>\n);
		$line .= qq(<div style="font-size:x-small;color:#080;$main::kborder_top_in$main::kpadding_normal_in">$guide_line</div>\n);

	}

	# ���f�X�N�g�b�v�ł̕\��
	else{
		$line .= qq(<div>\n);
		$line .= qq(<h1 id="subject">$h1_text</h1>\n);
		$line .= qq(</div>\n);
			if(!$my_use_device->{'smart_flag'}){
				$line .= qq(<div class="navilinks">$main::backurl_link </div>\n);
			}

			if($iframe_profile){
				$line .= qq($iframe_profile);
				$line .= qq(<h2>���e����</h2>);
			}
		$line .= qq(<div class="history_navigation size90">��ށF <span class="red">$history{'file_type_japanese'}</span> �� �L�^�J�n�F $first_how_before ( $first_date ) �� ���e�񐔁F $history{'regist_count'}��</div>\n);
		$line .= qq($history{'index_line'}\n);
		$line .= qq(<div><span class="guide">$guide_line</span></div>\n);
	}


# HTML���o��
Mebius::Template::gzip_and_print_all({},$line);

exit;

}


1;
