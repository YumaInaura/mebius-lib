
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
# 投稿履歴を取得 / 更新 
#-----------------------------------------------------------
sub get_reshistory{

# 宣言
my($type,$file,$use,$postdata,$maxview_index,undef,$maxview_one,$maxview_topics,$maxget_follow) = @_;
my($basic_init) = Mebius::basic_init();
my($param) = Mebius::query_single_param();
my($my_account) = Mebius::my_account();
my(%type,%post);
foreach(split(/\s/,$type)){	$type{$_} = 1; } # 処理タイプを展開
my(%got_topics); # ←こんな感じで、分けて局所化しないと mod_perl で不具合が？
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

# ディレクトリ定義
my($init_directory) = Mebius::BaseInitDirectory();
my($share_directory) = Mebius::share_directory_path();
my $directory1 = "${share_directory}_histories/";

# 設定
my $data_move_concept = "Data-moved-from-server1-2012.12.06";

	# ボットの場合、リターン
	if(Mebius::Device::bot_judge() && $type =~ /RENEW|My-file/){ return(); }

	# タイプ未指定の場合、環境変数をもとにタイプを代入する
	if($type =~ /My-file/ && $type !~ /(ACCOUNT|Open-account|CNUMBER|KACCESS_ONE|HOST|TRIP|ENCID|HANDLE|ISP)/){

			# 何でもホスト名を使ってしまうと、膨大なアクセス元からホスト名を逆引きしてしまうし、
			# 全く他人の閲覧履歴を見ることも出来てしまい、セキュリティ的に問題がある
			if($type =~ /RENEW|Allow-host/){ ($gethost) = Mebius::GetHostWithFile(); }

			if($my_account->{'login_flag'}){ $type .= " ACCOUNT"; }
			elsif($cnumber && $cookie){ $type .= " CNUMBER"; }
			elsif($kaccess_one){ $type .= " KACCESS_ONE"; }
			elsif($gethost && !$k_access){ $type .= " HOST"; } 
			else{ return; }

	}

	# 投稿履歴のタイプを定義
	if($type =~ /Crap-file/){
		$history{'history_type'} = "crap";
	} elsif($type =~ /Check-file/){
		$history{'history_type'} = "check";
	} else {
		$history{'history_type'} = "res";
	}

	# アカウント記録ファイルの場合
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
		$history{'file_type_japanese'} = "アカウント";
	}

	# クッキー記録ファイルの場合
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

	# 固体識別番号ファイルの場合
	elsif($type =~ /KACCESS_ONE/){

		# 局所化
		my($mobile_id,$mobile_uid);

		$max_line = 100;

		# アクセスデータを取得
		my($access) = Mebius::my_access();

			# 自分のデータを代入する場合
			if($file eq "" && $type =~ /My-file/){
				$mobile_id = $access->{'mobile_id'};
				$mobile_uid = $access->{'mobile_uid'};
			}

			# UAを分解する場合
			else{
				my($device) = Mebius::device({ UserAgent => $file });
				$mobile_id = $device->{'mobile_id'};
				$mobile_uid = $device->{'mobile_uid'};
			}


			# リターンする場合
			if($mobile_id eq "" || $mobile_uid eq ""){ return; }

		# エンコード
		my($mobile_id_encoded) = Mebius::Encode("",$mobile_id);
		my($mobile_uid_encoded) = Mebius::Encode("",$mobile_uid);


			# いいね！ファイル
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

	# ホストファイルの場合
	elsif($type =~ /HOST/){


			# 携帯の場合はホスト名をチェックしない ( 自分のファイルの場合 )
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

	# ISPファイルの場合
	elsif($type =~ /ISP/){

			# 携帯の場合はISPをチェックしない ( 自分のファイルの場合 )
			#if($type =~ /My-file/ && $k_access){ return(); }

		# ISP名を取得
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

	# トリップファイルの場合
	elsif($type =~ /TRIP/){
		$max_line = 200;
			if($file eq ""){ return(); }
		$file =~ s/!/\//g;
		$file =~ s/~/\./g;
		($file) = Mebius::Encode("",$file);
		$directory2 = "${directory1}_reshistory_trip/";
		$history_file = "${directory2}${file}_reshistory_trip.log";
		$history{'file_type'} = "trip";
		$history{'file_type_japanese'} = "トリップ";
	}

	# IDファイルの場合
	elsif($type =~ /ENCID/){
		$max_line = 200;
			if($file eq ""){ return(); }
		($file) = Mebius::Encode("",$file);
		$directory2 = "${directory1}_reshistory_id/";
		$history_file = "${directory2}${file}_reshistory_id.log";
		$history{'file_type'} = "encid";
		$history{'file_type_japanese'} = "ID";
	}

	# 公開用のアカウントファイルの場合
	elsif($type =~ /Open-account/){
		$max_line = 200;
			if(Mebius::Auth::AccountName(undef,$file)){ return(); }
			if($file eq ""){ return(); }
		($file) = Mebius::Encode("",$file);
		$directory2 = "${directory1}_reshistory_open_account/";
		$history_file = "${directory2}${file}_reshistory_open_account.log";
		$history{'file_type'} = "open-account";
		$history{'file_type_japanese'} = "アカウント(公開)";
	}

	# 筆名ファイルの場合
	elsif($type =~ /HANDLE/){
		$max_line = 100;
			if($file eq ""){ return(); }
		($file) = Mebius::Encode("",$file);
		$directory2 = "${directory1}_reshistory_handle/";
		$history_file = "${directory2}${file}_reshistory_handle.log";
		$history{'file_type'} = "handle";
	}

	# タイプ未指定の場合、リターン ( 2 )
	else{ return; }


$history{'access_target'} = $file;

	# 支持ファイルの場合、最大行数を変更する
	if($type =~ /Crap-file|Check-file/){ $max_line = 10; }
	else { $type .= qq( Res-file); }

	# CSS定義 ( インデックス )
	my($per_page,$per_first_page);
	if($type =~ /INDEX/){
		$css_text .= qq(
		.newres{font-size:100%;color:#f00;}
		.mylastdate{font-size:90%;color:#355;}
		th.justy,td.justy{text-align:right;}
		th{text-align:left;}
		);

		# スマフォ版を除くCSS (マイページ用)
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

	# 最大表示数 / 取得数の設定
	if(!$maxview_index){ $maxview_index = $max_line; }
	if($my_use_device->{'type'} eq "Mobile" && $maxview_index > 20){ $maxview_index = 20; }

	if(!$maxview_one){ $maxview_one = 5; }
	if(!$maxview_topics){ $maxview_topics = 10; }
	if(!$maxget_follow){ $maxget_follow = 10; }

	# ファイル読み込み
	if($type =~ /File-check-error/){ open($filehandle1,"+<",$history_file) || main::error("この投稿履歴は存在しません。[hs001] "); }
	elsif($type =~ /File-check-return/){ open($filehandle1,"+<",$history_file) || return(); }
	else{ open($filehandle1,"+<",$history_file) || ($file_nothing_flag = 1); }

	if($file_nothing_flag && $type =~ /RENEW/){
		Mebius::Mkdir(undef,$directory1);
		Mebius::Mkdir(undef,$directory2);
		Mebius::Fileout("Allow-empty Check",$history_file);
		open($filehandle1,"+<",$history_file);
	}

	# ファイルロック
	if($type =~ /RENEW/){ flock($filehandle1,2); }

	# トップデータ
	if($type !~ /OLD/){ $top = <$filehandle1>; chomp $top; }

# 局所化 ( トップデータの中で、まだハッシュとして扱っていない文字列 )
my($tunique,$tid,$tcnumber,$tpmfile,$tkaccess_one,$tk_access,$taddr,$thost,$tagent,$tlastcomment,$tcharge_ressecond,$tcharge_postsecond,$tcnumbers,$thosts,$taccounts,$tagents,$temails,$tnames,$ttrips,$tlast_deadlink_checktime,$tencids,$tall_thread);

# トップデータを分解
($history{'key'},$history{'lasttime'},$history{'first_time'},$history{'renew_time'},$tunique,$tid,$tcnumber,$tpmfile,$tkaccess_one,$tk_access,$taddr,$thost,$tagent,$tlastcomment,$tcharge_ressecond,$tcharge_postsecond,$tcnumbers,$thosts,$taccounts,$tagents,$temails,$tnames,$ttrips,$tlast_deadlink_checktime,$history{'regist_count'},$tencids,$tall_thread,$history{'make_account_blocktime'},$history{'last_renew_status_time'},$history{'last_regist_time_per_hour'},$history{'all_length_per'},$history{'make_accounts'},$history{'regist_count_per'},$history{'concept'}) = split(/<>/,$top);

	# フラグ 2012/12/6 (木) 旧サーバーのデータを統合する
	if($history{'concept'} !~ /$data_move_concept/ && $history{'first_time'} < 1354843578 && (Mebius::Server::bbs_server_judge() || Mebius::alocal_judge())){ #$my_account->{'master_flag'}
		$type .= qq( RENEW);
		$join_file_flag = 1;
	}

	# ハッシュ調整
	if(!$file_nothing_flag){ $history{'f'} = 1; }

	# １時間に１度更新される time ( 投稿文字数ブロックのためなどに使う )
	if(time > $history{'last_regist_time_per_hour'} + (1*60*60)){
		$history{'all_length_per'} = 0;
		$history{'regist_count_per'} = 0;
	}

	# 各記事を取得しての更新間隔を定義 ( 注意 … 分単位ではなく”秒”単位！ )

	# ●最近のレスの更新間隔を定義
	if($type =~ /Allow-renew-status/){

			if($type =~ /TOPICS/){
					if(Mebius::alocal_judge()){ $renew_status_interval_second = 1*15; }
					else{ $renew_status_interval_second = 1*30; }
			}


			# ▼各スレッド情報・更新用の判定
			# && $ENV{'REQUEST_METHOD'} eq "GET"

			if($history{'f'} && $type =~ /(ACCOUNT|CNUMBER|KACCESS_ONE)/ && !Mebius::Device::bot_judge()){
				$RENEW_STATUS_FLAG = 1;

				$history{'last_renew_status_time'} = time;
			}

	}

	# 新規作成時、トップデータがない場合に補完する
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

	# ファイル更新時、入力データがない場合に補完する
	if($type =~ /RENEW/){
			if($pcharge_ressecond eq ""){ $pcharge_ressecond = $tcharge_ressecond; }
			if($pcharge_postsecond eq ""){ $pcharge_postsecond = $tcharge_postsecond; }
	}

	# ●ハッシュを代入
	if($type =~ /(Get-hash|TOPDATA)/){

			# 基本ハッシュ
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

			# 追加のハッシュを定義
			my($other_counts);
				if($type =~ /Get-hash-detail/){
					foreach(split(/\s/,$thosts)){ $history{'other_counts'}++; }
					foreach(split(/\s/,$tagents)){ $history{'other_counts'}++; }
					foreach(split(/\s/,$tcnumbers)){ $history{'other_counts'}++; }
					foreach(split(/\s/,$taccounts)){ $history{'other_counts'}++; }
				}
			($history{'first_date'}) = Mebius::Getdate(undef,$history{'firsttime'});

	}

	# ●ファイルを展開◆◆
	while(<$filehandle1>){
		push(@file,$_);
	}

	# ●DBIから更新情報を取得する
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

	# ●ファイルを展開◆◆
	foreach(@file){

		my(%data);

		# ファイルの行を分解
		chomp;
	my($thread_last_restime2,$thread_lasthandle2);
	my($thread_keylevel2);
		(undef,$data{'concept'},$data{'subject'},$data{'thread_number'},$data{'res_number_histories'},$data{'bbs_kind'},$data{'bbs_title'},undef,$data{'my_regist_time'},$data{'server_domain'},undef,$data{'handle'},undef,$data{'deleted_resnumber_histories'},undef,undef,undef,undef,undef,$data{'last_read_thread_time'},$data{'last_read_res_number'}) = split(/<>/);
	push @{$history{'res_line_data'}} , \%data;

		# 局所化
		my($viewkey2,@resnumber_histories2,$not_view_line,$escape_index_flag,$escape_flag,$myres_count2,$relay_type2,$already_read_flag2,$unread_res_number2);

		# ラウンドカウンタ
		$i++;

			# 書き込んだスレッド 番号/ レス番情報だけを配列にして抽出する ( 管理用 => 投稿履歴からの一斉削除時に利用 )
			if($type{'GetAllThreadAndRes'}){
					foreach my $res_number (split(/\s/,$data{'res_number_histories'})){
						$history{'AllRegist'}{$data{'bbs_kind'}}{$data{'thread_number'}}{$res_number} = 1;
					}
			}

			# 必須データがない場合、壊れている場合、どの処理でもエスケープする
			if($data{'bbs_kind'} eq "" || $data{'bbs_title'} eq "" || $data{'thread_number'} eq ""){ next; }
			if($data{'thread_number'} =~ /\D/ || $data{'bbs_kind'} =~ /\W/){ next; }

			# 複数のレス番を整形
			my @deleted_resnumber_histories2 = split(/\s/,$data{'deleted_resnumber_histories'});
			foreach(split(/\s|,/,$data{'res_number_histories'})){
				push(@resnumber_histories2,$_);
			}
		my($res_number2) = $resnumber_histories2[0];

			# レス投稿回数を定義
			$myres_count2 = @resnumber_histories2 + @deleted_resnumber_histories2;

		# ◆トップデータのハッシュ化 - インデックスの１行目だけは取得する (A-1)
		if($i == 1 && $type =~ /(TOPDATA|Get-hash-only)/){
			$history{'lastsub'} = $data{'subject'};
			$history{'lastmoto'} = $data{'bbs_kind'};
			$history{'lastno'} = $data{'thread_number'};
			$history{'lastres'} = $res_number2;

				# ファイルハンドルを閉じて、このままリターンする
				if($type =~ /TOPDATA|Get-hash-only/){
					close($filehandle1);
					return(%history);
				}

		}

			# ひとつの掲示板内で、最近レスをしたかどうかを調査
			if($type =~ /Get-lastres-time/){
					if($res_number2 >= 1 && $data{'bbs_kind'} eq $search_moto && $data{'concept'} !~ /Self-thread/){
						$lastrestime_bbs = $data{'my_regist_time'};
						last;
					}
			}

			# 隠し行の場合 ( エスケープしたら困る処理に注意。この位置を間違えないように )
			if($data{'concept'} =~ /Hidden/ && $type !~ /Admin/){ $escape_flag = 1; }
			if($data{'server_domain'} eq ""){ $escape_flag = 1; }

			# 最近投稿した掲示板の一覧を取得する
			if($type =~ /BBS-list/ && !$bbslist{$data{'bbs_kind'}} && !$escape_flag){
				push(@bbslist,"$data{'bbs_kind'}=$data{'bbs_title'}");
				$bbslist{$data{'bbs_kind'}} = 1;
			}

			# ◆スレッドを取得◆
			if($RENEW_STATUS_FLAG){

					# ○スレッドを取得しない場合 ( elsif else を繋げるように )
					if($escape_flag){

					# ▼スレッドを取得する場合
					} elsif($thread_status_from_dbi && Mebius::Switch::dbi_new_res_history()){

							# DBI による新しい取得判定処理
							my $dbi_data = $thread_status_from_dbi->{$data{'bbs_kind'}}->{$data{'thread_number'}};

							# ▼レコードが存在する場合
							if(exists $thread_status_from_dbi->{$data{'bbs_kind'}}->{$data{'thread_number'}}){

									$hit_get_thread++;

									$data{'last_res_number'} = $dbi_data->{'res_number'};
									$thread_last_restime2 = $data{'last_res_time'} = $dbi_data->{'regist_time'};

									$data{'subject_dbi'} = $dbi_data->{'subject'};
									$data{'last_handle_dbi'} = $dbi_data->{'handle'};

									($data{'subject'}) = shift_jis_return($dbi_data->{'subject'});
									($thread_lasthandle2) = shift_jis_return($dbi_data->{'handle'});

								# ▼レコードが存在しない場合、自動的にデータベースに追加する
								} elsif(rand(1) < 1) {

									my($thread) = Mebius::BBS::thread_state($data{'thread_number'},$data{'bbs_kind'});
									($data{'subject_dbi'}) = utf8_return($thread->{'subject'});
									($data{'last_handle_dbi'}) = utf8_return($thread->{'lasthandle'});

										# 同時にデータベースに登録
										if($thread->{'f'}){
											#Mebius::BBS::ThreadStatus->update_table({ update => { bbs_kind => $data{'bbs_kind'} , thread_number => $data{'thread_number'} , res_number => $thread->{'res'} , regist_time => $thread->{'lastrestime'} , subject => $data{'subject_dbi'} , handle => $data{'last_handle_dbi'} } });
											my $thread_utf8 = hash_to_utf8($thread);
											Mebius::BBS::ThreadStatus->update_table($thread_utf8);
										}

										# 今回のセッションにすぐにデータを
										$data{'last_res_number'} = $thread->{'res'};
										$thread_last_restime2 = $data{'last_res_time'} = $thread->{'lastrestime'};
										$data{'subject'} =  $thread->{'subject'};
										$thread_lasthandle2 = $thread->{'lasthandle'}; 
										$data{'last_handle'} = $thread_lasthandle2;

								}

						}
			}

			# ▼既読管理 (D-1)
			{
					# 投稿履歴を閲覧状態にする (E-1)
					if($use->{'ReadThread'}){

							if($q->param('moto') eq $data{'bbs_kind'} && $q->param('no') eq $data{'thread_number'}){
								$data{'last_read_thread_time'} = time;
								$read_thread_hit_flag = 1;
									if($use->{'read_thread_res_number'} =~ /^[0-9]+$/){
										$data{'last_read_res_number'} = $use->{'read_thread_res_number'};
									}
							}
					}

					# 既読判定 (E-2)
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

			# ◆トピックスを配列に追加 ( D02 )
			if($type =~ /TOPICS/ && !$escape_flag){
				$got_topics{"$data{'bbs_kind'}-$data{'thread_number'}"} = 1;
				$i_topics++;
				
					# いいね！ファイルの場合
					#if($type{'Crap-file'}){ $relay_type2 .= qq( Crap); }
					#elsif($type{'Check-file'}){ $relay_type2 .= qq( Check); }

					$data{'history_type'} = $history{'history_type'};
					push(@topics, \%data);
			}

			# ◆”簡易”投稿履歴を取得◆
			if($type =~ /ONELINE/ && $hit_one < $maxview_one && !$escape_flag){
				my($newmark_oneline,$class);
				$hit_one++;
					if($thread_last_restime2 > $data{'my_regist_time'} && $thread_lasthandle2){
						$newmark_oneline = qq( ( <a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}.html#S$data{'last_res_number'}"$class>$thread_lasthandle2</a> ) );
					}

					# 携帯版
					if($my_use_device->{'mobile_flag'}){
						$one_line .= qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}.html#S$res_number2">$data{'subject'}</a>$newmark_oneline<br />);
					}

					# PC版
					else{
							if($hit_one >= 2){ $one_line .= qq( / ); }
						$one_line .= qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}.html#S$res_number2">$data{'subject'}</a>$newmark_oneline);
					}
			}

			# ◆フォローを代入する掲示板の種類を取得◆
			if($type =~ /FOLLOW/ && $hit_follow < $maxget_follow && !$escape_flag){
				$hit_follow++;
				push(@follow_bbs,$data{'bbs_kind'});
			}

			# ◆インデックスを取得用の処理
			if($type =~ /INDEX/){

				# インデックス用のラウンドカウンタ
				$i_index++;

					# 自分以外には見せない掲示板/記事
					if($data{'concept'} =~ /(secret|Deleted-thread)/ || ($res_number2 eq "" && $type =~ /Res-file/) || $data{'bbs_kind'} =~ /(^sc)/){ #  || $thread_keylevel2 < 0
							# 非表示行でも、印付きで表示する場合
							if($myhistory_flag || $type =~ /Admin/){ $viewkey2 .= qq( <span class="alert">[ 非表\示 ]</span>); }
							else{ $escape_index_flag = 1; }
					}

			}

			# ◆インデックスを取得◆
			if($type =~ /INDEX/ && $hit_index < $maxview_index && !$escape_flag && !$escape_index_flag && !Mebius::Fillter::heavy_fillter(utf8_return($data{'subject'}))){

				# 局所化
				my($resmark,$view_lasthandle,$lastminute,$view_mylasttime,$view_mylasttime_link,$mark2,$backurl_encoded);
				my($delete_res_reason);

					# キーを見せる場合
					if($my_account->{'admin_flag'} >= 1 || $type =~ /Admin/){ $viewkey2 .= qq( $data{'concept'}); }

					# 管理モードでの戻り先をエンコード
					if($type =~ /Admin/){
						$backurl_encoded = Mebius::Encode(undef,"$basic_init->{'main_url'}?$main::postbuf#HISTORY");
							if($param->{'comment_control'}){ $delete_res_reason .= qq(&amp;comment_control=).e($param->{'comment_control'}); }
							if($param->{'handle'}){ $delete_res_reason .= qq(&amp;handle=).e($param->{'handle'}); }
					}

					# 自分が作成した記事
					if($data{'concept'} =~ /Self-thread/){ $mark2 .= qq( <span style="color:#f00;">[ 作成者 ]</span>); }

					# 筆名の扱い
					if($data{'concept'} =~ /Handle-deleted/){ $data{'handle'} = qq(投稿); }

				# カウント
				$hit_index++;

					# 自分の投稿時刻（何分前～何日前か）を定義
					if($data{'my_regist_time'}){
						($view_mylasttime) = Mebius::SplitTime("Get-top-unit Blank-view Plus-text-前",time - $data{'my_regist_time'});
					}

				# 何ページ目へのリンクか
				my($plustype_page_number);
					if($type =~ /Admin/){ $plustype_page_number .= qq( Admin-view);  }
				my($page_number_lasttime) = Mebius::Page::NowPagenumber("$plustype_page_number",$res_number2,$data{'last_res_number'},$per_page,$per_first_page);

					# リンク設定 
					if($type =~ /Admin/){
						$view_mylasttime_link = qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}$page_number_lasttime&amp;backurl=$backurl_encoded#S$res_number2" class="mylasttime">$view_mylasttime</a>); 
					}
					else{
						#$view_mylasttime_link = qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}$page_number_lasttime.html#S$res_number2" class="mylasttime">$view_mylasttime</a>);
						$view_mylasttime_link = qq($view_mylasttime);
					}

					# いいね！ファイルの場合
					if($type{'Crap-file'} || $type{'Check-file'}){
						$view_mylasttime_link = $view_mylasttime;
					}


				# 筆名リンクの整形
				my $res_number_view = "($res_number2)" if($my_use_device->{'narrow_flag'} && defined $res_number2);

					# ●最近の更新 - 公開履歴 ( 筆名リンク )
					if($type =~ /Open-view/){

						my($page_number_open_view) = Mebius::Page::NowPagenumber("$plustype_page_number",$res_number2,undef,$per_page);

							# 筆名がない場合は代入
							if($data{'handle'} eq ""){ $data{'handle'} = "投稿"; }

							# 管理用
							if($type =~ /Admin/){
								$view_lasthandle = qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}$page_number_open_view&amp;backurl=$backurl_encoded#S$res_number2">$data{'handle'}$res_number_view </a>);
							}
							# 一般用
							else{
								$view_lasthandle = qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}$page_number_open_view.html#S$res_number2">$data{'handle'}$res_number_view </a>);
							}

							# 本人が投稿した時刻を定義
							if($data{'my_regist_time'}){
								($lastminute) = Mebius::SplitTime("Get-top-unit Blank-view Plus-text-前 Color-view-else",time - $data{'my_regist_time'});
							}
					}

					# ●最近の更新 - 非公開履歴
					else{
							# 最終投稿者の筆名
							if($thread_lasthandle2){
								$view_lasthandle = qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/$data{'thread_number'}.html#S$data{'last_res_number'}">$thread_lasthandle2$res_number_view </a>);
							}
							# 最新レスの経過時間を表示
							if($thread_last_restime2){
								($lastminute) = Mebius::SplitTime("Get-top-unit Color-view-else Plus-text-前",time - $thread_last_restime2);
							}
					}

				# 筆名部分の整形
				if($view_lasthandle){
						if($my_use_device->{'wide_flag'}){
								# 未読数の表示
								if($unread_res_number2 >= 1){
									$view_lasthandle = "( $view_lasthandle <strong class=\"new margin\">$unread_res_number2</strong> )";
								} else {
									$view_lasthandle = "( $view_lasthandle )";
								}

						}
				}

					# ●表示内容 ( モバイル )
					#if($my_use_device->{'type'} eq "Mobile"){
					if($my_use_device->{'narrow_flag'}){

						my($div_style,$def_back);
							if($hit_index % 2 == 0){ $div_style = qq( style="background:#eee;"); $def_back = " def_back"; }

							if($my_use_device->{'smart_flag'}){
								$index_line .= qq(<div class="els$def_back">);
							} else {
								$index_line .= qq(<div$div_style>);
							}

							# コントロール用
							if($type =~ /Mypage-view/){
								$index_line .= qq(<input type="checkbox" name="history-$data{'bbs_kind'}-$data{'thread_number'}" value="delete"$main::xclose> \n);
							}

						$index_line .= qq(<a href="/_$data{'bbs_kind'}/$data{'thread_number'}.html">$data{'subject'}</a>);

							# 掲示板リンク
							if($my_use_device->{'mobile_flag'}){
								$index_line .= qq(<div style="text-align:right;">);
							} else {
								$index_line .= qq(<div class="right">);
							}
						$index_line .= qq(<a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/">$data{'bbs_title'}</a>);
						$index_line .= qq(</div>);

							# 筆名リンク
							if($my_use_device->{'mobile_flag'}){
								$index_line .= qq(<div style="text-align:right;">);
							} else {
								$index_line .= qq(<div class="right">);
							}
						$index_line .= qq($lastminute - );
						$index_line .= qq($view_lasthandle);
						$index_line .= qq(</div>);


	
						# 全体の閉じタグ
						$index_line .= qq(</div>\n);

					}

					# ●表示内容 ( デスクトップ )
					else{
						$index_line .= qq(<tr>);
						$index_line .= qq(<td>);

							# ▼記事へのリンク
							if($type =~ /Admin/){
								$index_line .= qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}&amp;backurl=$backurl_encoded">$data{'subject'}</a>);
							}
							else{
								$index_line .= qq(<a href="/_$data{'bbs_kind'}/$data{'thread_number'}.html">$data{'subject'}</a>);
							}

						$index_line .= qq($viewkey2);
						$index_line .= qq($mark2);
						$index_line .= qq(</td>);

						# ▼最終レスをした筆名
						$index_line .= qq(<td>);
						$index_line .= qq($view_lasthandle);
						$index_line .= qq(</td>);


						# ▼ 
						$index_line .= qq(<td class="right">$lastminute</td>);

							# ○掲示板へのリンク
							if($type =~ /Admin/){
								$index_line .= qq(<td><a href="${main::jak_url}$data{'bbs_kind'}.cgi">$data{'bbs_title'}</a></td>);
							}
							else{
								$index_line .= qq(<td><a href="http://$data{'server_domain'}/_$data{'bbs_kind'}/">$data{'bbs_title'}</a></td>);
							}

				
							# レス番を展開
							my @all_res_numbers = sort { $b <=> $a } (@resnumber_histories2,@deleted_resnumber_histories2);
							my @res_numbers = sort { $b <=> $a } @resnumber_histories2;
							my @deleted_res_numbers = sort { $b <=> $a } @deleted_resnumber_histories2;

							my $all_res_numbers = join "," , @all_res_numbers;
							my $res_numbers = join "," , @res_numbers;
							my $deleted_res_numbers = join "," , @deleted_res_numbers;

							my $all_res_count = @all_res_numbers;
							my $res_count = @res_numbers;
							my $deleted_res_count = @deleted_res_numbers;

							# 非公開履歴 - 自分の投稿時刻
							if($type !~ /Open-view/){
								#$index_line .= qq(<td class="justy"><a href="/_$data{'bbs_kind'}/$data{'thread_number'}.html-$all_res_numbers" rel="nofollow">${myres_count2}回</a></td>);
								$index_line .= qq(<td class="justy">$view_mylasttime_link</td>);
							}

							# 公開履歴 - 投稿回数
							{
									# ▼管理用
									if($type =~ /Admin/){

										$index_line .= qq(<td class="justy">);
											
										#$index_line .= qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}&amp;No=$res_numbers$delete_res_reason#RESNUMBER">${res_count}回</a>\n); 
										#$index_line .= qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}&amp;No=$deleted_res_numbers$delete_res_reason#RESNUMBER">${deleted_res_count}回</a>\n); 
										$index_line .= qq(<a href="${main::jak_url}$data{'bbs_kind'}.cgi?mode=view&amp;no=$data{'thread_number'}&amp;No=$all_res_numbers$delete_res_reason#RESNUMBER">${all_res_count}回</a>\n); 

										#&amp;&view_only_this_number=1&amp;backurl=$backurl_encoded
										$index_line .= " ( " . (@resnumber_histories2). "回 )";
										$index_line .= qq(</td>);
									}
									# 一般用
									else{
											if(Mebius::Device::bot_judge()){
												$index_line .= qq(<td>${myres_count2}回</td>);
											} else {
												$index_line .= qq(<td class="justy"><a href="/_$data{'bbs_kind'}/$data{'thread_number'}.html-$all_res_numbers" rel="nofollow">${myres_count2}回</a></td>);
											}
									}
							}


							# コントロール用
							if($type =~ /Mypage-view/){
								$index_line .= qq(<td><input type="checkbox" name="history-$data{'bbs_kind'}-$data{'thread_number'}" value="delete"></td>\n);
							}


						$index_line .= qq(</tr>\n);
					}
			}

			# 投稿履歴を全て削除する
			if($type =~ /UNLINK/ && $data{'concept'} !~ /Hidden/){
				$data{'concept'} .= qq( Hidden);
			}

			# 投稿履歴を指定削除する (複数選択可能)
			if($type =~ /Control-history/){
					foreach(split(/&/,$main::postbuf)){
						my($key,$value) = split(/=/,$_);
							if($key =~ /^\Qhistory-${data{'bbs_kind'}}-${data{'thread_number'}}\E$/){
									if($value eq "delete" && $data{'concept'} !~ /Hidden/){ $data{'concept'} .= qq( Hidden); }
							}
					}
			}


			# ◆関連記事登録のための処理◆
			if($type =~ /KRCHAIN/ && !$escape_flag){

					# 重複した記事はエスケープする
					if($data{'bbs_kind'} eq $prealmoto && $data{'thread_number'} eq $pi_postnumber){ next; }

					# 各種ネクスト
					if($data{'concept'} =~ /(nokr|secret)/){ next; }
					elsif($data{'bbs_kind'} =~ /(^sub|^sc)/){ next; }
					elsif($prealmoto == $data{'bbs_kind'} && $data{'thread_number'} == $pi_postnumber){ next; }
					else{ @krchain_line = ($data{'thread_number'},$data{'bbs_kind'},$data{'subject'},$data{'server_domain'}); last; }

			}

			# ●ファイル更新用 ( While の途中で $type .= " RENEW" を指定したりすると、それ以前の行は消えてしまう可能性があるので注意 )
			my $next_flag_closure; # クロージャの中で next; を使うと変になるので、フラグを利用
			{

					# 同じ記事はエスケープ
					if($type =~ /(REGIST|New-crap|New-check)/ && $data{'bbs_kind'} eq $prealmoto && $data{'thread_number'} eq $pi_postnumber){

						# 一分の情報は覚えておいて、あとで新しい行に反映する
						$keep_res_number_histories = $data{'res_number_histories'};
							if($data{'concept'} =~ /Self-thread/){ push(@newkey2,"Self-thread"); }
							$pdeleted_resnumber_histories = $data{'deleted_resnumber_histories'};

						$next_flag_closure = 1;

					}

					# レスの削除 ( １記事あたりの投稿回数の減算 )
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

					# 行 ( 記事１個 ) の削除
					if($type =~ /Delete-thread/ && $data{'concept'} !~ /Deleted-thread/){
							if("$delete_realmoto-$delete_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								$data{'concept'} .= qq( Deleted-thread);
							}
					}

					# 筆名の削除
					if($type =~ /Delete-handle/ && $data{'concept'} !~ /(Handle-deleted)/){
							if("$delete_realmoto-$delete_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								$data{'concept'} .= qq( Handle-deleted);
							}
					}

					# 行( 記事１個 ) の復活
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

					# 行の復活
					if($type =~ /Repair-thread/ && $data{'concept'} =~ /Deleted-thread/){
							if("$repair_realmoto-$repair_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								$data{'concept'} =~ s/(\s?)Deleted-thread//g;
							}
					}

					# 筆名の復活
					if($type =~ /Repair-handle/ && $data{'concept'} =~ /Handle-deleted/){
							if("$repair_realmoto-$repair_thread_number" eq "$data{'bbs_kind'}-$data{'thread_number'}"){
								$data{'concept'} =~ s/(\s?)Handle-deleted//g;
							}
					}

					# 全記事数をフック
					if($data{'concept'} !~ /Deleted-thread/ && $myres_count2 >= 1){ $tall_thread_buffer++; }

			}
			if($next_flag_closure){ next; }

			# ▼ 更新行の追加 ( 実際はファイル更新しない場合でも、ファイル消失を予防するために、変数として追加しておく )
			# 同じスレッドの重複を回避
			if($renew_line_redun{$data{'server_domain'}}{$data{'bbs_kind'}}{$data{'thread_number'}}){
				0;
			# 更新行を追加
			} elsif($hit_renew <= $max_line){

				$hit_renew++;
push(@renew_line,"<>$data{'concept'}<>$data{'subject'}<>$data{'thread_number'}<>$data{'res_number_histories'}<>$data{'bbs_kind'}<>$data{'bbs_title'}<><>$data{'my_regist_time'}<>$data{'server_domain'}<><>$data{'handle'}<><>$data{'deleted_resnumber_histories'}<>$thread_last_restime2<>$data{'last_res_number'}<>$thread_lasthandle2<>$thread_keylevel2<><>$data{'last_read_thread_time'}<>$data{'last_read_res_number'}<>\n");
				$renew_line_redun{$data{'server_domain'}}{$data{'bbs_kind'}}{$data{'thread_number'}} = 1;
			}

	# While 処理終わり
	}


	# 更新判断
	if($use->{'ReadThread'} && $read_thread_hit_flag){
		$type .= qq( RENEW);
	}


	# ▼ データ記録
	if($type =~ /RENEW/ && $type =~ /My-file/){

		# 各種情報を取得
		my($myaddress) = Mebius::my_address();

		# 局所化
		my(@tcnumbers,@thosts,@taccounts,@tagents,@ttrips,@temails,@tnames,@tencids);
		my($i_tcnumbers,$i_thosts,$i_taccounts,$i_tagents,$i_emails,$i_trips,$i_names,$i_encids);

			# 管理番号履歴を展開
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

			# ユーザーエージェント履歴を展開
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

			# ホスト名履歴を展開
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

			# アカウント名履歴を展開
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

			# メールアドレスを展開
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

			# 筆名を展開
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

			# トリップを展開
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

			# IDを展開
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

	# ●ファイルを更新
	if($type =~ /RENEW/){

			# ▼投稿記録時の処理
			if($type =~ /REGIST/){

					# 新しい行の【第二キー】を定義
					if($secret_mode || $concept =~ /NOT-KR/ || $subtopic_mode){ push(@newkey2,"nokr"); }
					if($secret_mode){ push(@newkey2,"secret"); }
					if($pi_resnumber eq "0"){ push(@newkey2,"Self-thread"); }
					if($type =~ /New-line-hidden/){ push(@newkey2,"Hidden"); }

				$newkey = 1;

				# 本文の長さを判定
				my($comment) = ($pcomment);
				$comment =~ s/( |　|<br>)//g;
				$plength = int(length($pcomment) / 2);

					# 文字数関連
					if(!$history{'last_regist_time_per_hour'} || time > $history{'last_regist_time_per_hour'} + (1*60*60)){
						$history{'last_regist_time_per_hour'} = time;
					}
				$history{'all_length_per'} += $plength;

					# 新しいレス番
					if(defined($keep_res_number_histories)){ $new_resnumber_histories = join " " , ($pi_resnumber,$keep_res_number_histories); }
					else{ $new_resnumber_histories = $pi_resnumber; }

				# 新しく追加する行
				$tall_thread_buffer++;

				# トップデータに代入
				$tlastcomment = $pcomment;
				$history{'regist_count'}++;
				$history{'regist_count_per'}++;
			}


			# ▼新しく追加する行
			if($type =~ /(REGIST|New-crap|New-check)/){

				# 元記事を取得
				my(%thread) = Mebius::BBS::thread({},$prealmoto,$pi_postnumber);

				# 追加行
unshift(@renew_line,"$newkey<>@newkey2<>$thread{'subject'}<>$pi_postnumber<>$new_resnumber_histories<>$prealmoto<>$ptitle<>$main::date<>$time<>$pserver_domain<><>$phandle<>$pencid<>$pdeleted_resnumber_histories<>$thread{'lastrestime'}<>$thread{'res'}<>$thread{'lasthandle'}<>$thread{'keylevel'}<><>$time<>\n");



			}

			# ▼投稿履歴リセット時の、トップデータの処理
			if($type =~ /UNLINK/){
				$tnames = undef;
			}

			# ▼アカウントの新規作成
			if($type =~ /Make-account/){

					# 連続作成制限
					if($history{'make_account_blocktime'} < $renew{'make_account_blocktime'}){
						$history{'make_account_blocktime'} = $renew{'make_account_blocktime'};
					}

					# アカウント作成履歴を追加
					if($history{'make_accounts'}){ $history{'make_accounts'} = qq($renew{'plus_make_accounts'} $history{'make_accounts'}); }
					else{ $history{'make_accounts'} .= $renew{'plus_make_accounts'}; }

			}

			# ▼ハッシュ一斉操作
			if(%renew){
				my($renew) = Mebius::Hash::control(\%history,\%renew);
				($renew) = Mebius::format_data_for_file($renew);
				%history = %$renew;
			}


			# ▼全記事数を記録
			if(defined($tall_thread_buffer)){ $tall_thread = $tall_thread_buffer; }

			# ▼トップデータを変更
			if($type =~ /(REGIST|New-crap|New-check)/){
				$taddr = $ENV{'REMOTE_ADDR'};
			}

			# ▼自分のデータの場合
			if($type =~ /My-file/){
				$history{'lasttime'} = time;
			}

		# トップデータを追加
	unshift(@renew_line,"$history{'key'}<>$history{'lasttime'}<>$history{'first_time'}<>$history{'renew_time'}<>$tunique<>$pid<><><><><>$taddr<><><>$tlastcomment<>$pcharge_ressecond<>$pcharge_postsecond<>$tcnumbers<>$thosts<>$taccounts<>$tagents<>$temails<>$tnames<>$ttrips<>$tlast_deadlink_checktime<>$history{'regist_count'}<>$tencids<>$tall_thread<>$history{'make_account_blocktime'}<>$history{'last_renew_status_time'}<>$history{'last_regist_time_per_hour'}<>$history{'all_length_per'}<>$history{'make_accounts'}<>$history{'regist_count_per'}<>$history{'concept'}<>\n");

		# 更新
		seek($filehandle1,0,0);
		truncate($filehandle1,tell($filehandle1));
		print $filehandle1 @renew_line;

	}

close($filehandle1);

	# パーミッション変更
	if($type =~ /RENEW/){ Mebius::Chmod(undef,$history_file); }

		# チェック履歴の取得、追加
		if($type =~ /TOPICS/){
				if($type =~ /TOPICS-get-only/){ return(@topics); }
			my(@check_topics) = main::get_reshistory("TOPICS-get-only Check-file My-file Allow-renew-status",undef,$use,%got_topics);
			push(@topics,@check_topics);
		}

		# トピックスの整形
		if($type =~ /TOPICS/ && @topics){
			($topics_line) = Mebius::History->topics($maxview_topics,@topics);
			$topics_line;
		}

		# １行履歴の整形
		if($type =~ /ONELINE/ && $one_line){
				if($my_use_device->{'type'} eq "Mobile"){ }
				else{
						if($one_line){ $one_line .= qq( / <a href="$basic_init->{'main_url'}?mode=my#RESHISTORY" class="green">…続きを見る</a>); }
					$one_line .= qq( / <a href="$basic_init->{'main_url'}?mode=my#EDIT">…設定</a>);
					$one_line = qq(<span class="one_line"><strong>履歴：</strong> $one_line</span>);
				}
		}

	# インデックスの整形
		if($type =~ /INDEX/ && $type !~ /OLD/ && $index_line){
			my($flowlink,$postbuf_enc) = ("",$postbuf);
				if($i_index > $maxview_index){ $index_flow = 1;	}

				# 携帯版
				#if($my_use_device->{'type'} eq "Mobile"){
				if($my_use_device->{'narrow_flag'}){
					$index_line = qq(<div style="$main::ktextalign_center_in">$index_line</div>$flowlink\n);
				}

				# デスクトップ版
				else{
						# 公開履歴
						if($type =~ /Open-view/){
							$index_line = qq(<table summary="投稿履歴" class="history_table width100">\n<tr><th>記事</th><th colspan="2">投稿</th><th>掲示板</th><th class="justy">投稿数</th></tr>\n$index_line</table>$flowlink);
						}

						# 非公開履歴 - いいね！
						elsif($type =~ /Crap-file|Check-file/){
							$index_line = qq(<table summary="投稿履歴" class="history_table width100">\n<tr><th>記事</th><th colspan="2">投稿</th><th>掲示板</th><th class="justy">時間</th></tr>\n$index_line</table>$flowlink);
						}

						# 非公開履歴 - レス投稿
						else{
							$index_line = qq(<table summary="投稿履歴" class="history_table width100">\n<tr><th>記事</th><th colspan="2">更新</th><th>掲示板</th><th class="justy">最終投稿</th><th class="justy">投稿数</th><th>▼</th></tr>\n$index_line</table>$flowlink);
						}


				}

				# 非公開履歴
				if($type =~ /Mypage-view/){
					$return_index_line .= qq(<form action="./?mode=my" method="post" utn="utn"><div>\n);
					$return_index_line .= qq(<input type="hidden" name="mode" value="my"$main::xclose>\n);
					$return_index_line .= qq(<input type="hidden" name="type" value="control_history"$main::xclose>\n);
						if($type{'Crap-file'}){ $return_index_line .= qq(<input type="hidden" name="target_file" value="crap"$main::xclose>\n); }
						elsif($type{'Check-file'}){ $return_index_line .= qq(<input type="hidden" name="target_file" value="check"$main::xclose>\n); }
						else{ $return_index_line .= qq(<input type="hidden" name="target_file" value="res"$main::xclose>\n); }
					$return_index_line .= qq($main::backurl_input\n);
					$return_index_line .= qq($index_line\n);
					$return_index_line .= qq(<div style="text-align:right;"><input type="submit" name="history_delete" value="履歴を削除する"$main::xclose></div>\n);
					$return_index_line .= qq(</div></form>$flowlink\n);
				}
				else{
					$return_index_line = $index_line;
				}

		}

	# 各種リターン
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
# DBIから更新情報をゲット
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
# DBIから更新情報をゲット
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
# 投稿履歴の表示ページ
#-----------------------------------------------------------
sub HistoryIndex{

# 宣言
my($type,$filetype,$file) = @_;
my($h1_text,$guide_line,$plustype_getres_history,$line,$iframe_profile);
my($my_use_device) = Mebius::my_use_device();
my($basic_init) = Mebius::basic_init();

# 自動リンク切れ修正をブロック
$main::not_repair_url_flag = 1;
$main::css_text .= qq(
iframe.sns_profile{border-style:none;width:100%;height:5.5em;}
);

	if($my_use_device->{'smart_flag'}){
		$main::css_text .= qq(.body1{width:100%;});
	}

	# 携帯版への対応
	if($my_use_device->{'type'} eq "mobile"){ main::kget_items(); }

	# Title定義
	$main::head_link2 = qq(&gt; 投稿履歴);

	# ファイル名
	my $view_filename = $file;
	$view_filename =~ s/!/\//g;
	$view_filename =~ s/~/\./g;

	# 管理タイプ
	if($type =~ /Admin-view/){
		$plustype_getres_history .= qq( Admin);
	}

	# 処理タイプを定義
	# トリップ
	if($filetype eq "trip"){
		$h1_text = "☆$view_filename の履歴";
		$main::sub_title = qq(☆$view_filename | トリップ);
		$main::head_link3 = qq(&gt; ☆$view_filename);
		$guide_line = qq(※履歴を追加したくない場合は<a href="${main::guide_url}%A5%C8%A5%EA%A5%C3%A5%D7">トリップガイド</a>をご覧ください。);
		$plustype_getres_history .= qq( TRIP);
	}
	# ID
	elsif($filetype eq "id"){
		$h1_text = "★$view_filename の履歴";
		$main::sub_title = qq(★$view_filename | ID);
		$main::head_link3 = qq(&gt; ★$view_filename);
		$plustype_getres_history .= qq( ENCID);
		$guide_line = qq(※IDは必ずしも、同一人物であることを保証するものではありません。環境によっては他の人と重なる場合があります。);
		#<br>※ID履歴を記録したくない場合はアカウントにログインした上で、投稿フォームで「ID履歴」の項目からチェックを外してください。
	}
	# アカウント
	elsif($filetype eq "account"){
		#$h1_text = qq(<a href=") . esc($basic_init->{'auth_url'}). esc($view_filename) . qq(/">). esc("\@$view_filename") . qq(</a> の情報);
		$h1_text = qq(\@$view_filename の履歴);

		$main::sub_title = qq(\@$view_filename | アカウント);
		$main::head_link3 = qq(&gt; \@$view_filename);
		$plustype_getres_history .= qq( Open-account);
			if(1){
				$iframe_profile = qq(<h2><a href=") . esc("$basic_init->{'auth_url'}$view_filename/#PROF") . qq(">プロフィール</a></h2>);
				$iframe_profile .= qq(<iframe src=") . esc($basic_init->{'auth_url'}) . qq(?mode=sns_profile_iframe&amp;account=) . esc($view_filename) . qq(" class="sns_profile"></iframe>);
				$iframe_profile .= qq(<div><a href=") . esc("$basic_init->{'auth_url'}$view_filename/") . qq(">→アカウントを全て表\示する</a></div>);
			}
	}

	else{ main::error("この表\示モードは存在しません。"); }

# CSS定義
$main::css_text .= qq(
div.navilinks{margin:1em 0em;}
table.history_table{margin:1em 0em;}
div.history_navigation{padding:0.5em 0.5em;background:#afa;}
);


# 投稿履歴ファイルを開く
my(%history) = main::get_reshistory("INDEX File-check-error Open-view Get-hash-detail $plustype_getres_history",$file);

	# 管理用にリンクを整形
	if($type =~ /Admin-view/){
		($history{'index_line'}) = Mebius::Adfix("Url",$history{'index_line'});
	}

# 初記録日を計算
my($first_date) = Mebius::Getdate(undef,$history{'first_time'}) if($history{'first_time'});
my($first_how_before) = shift_jis(Mebius::second_to_howlong({ GetLevel => "top" , ColorView => 1 , HowBefore => 1 } , time - $history{'first_time'})) if($history{'first_time'});

	# ▼モバイル版の表示
	if($my_use_device->{'mobile_flag'}){
		$line .= qq(<div style="$main::kbackground_blue2_in$main::kborder_bottom_in">\n);
		$line .= qq(<h1$main::kstyle_h1>$h1_text</h1>\n);
		$line .= qq(</div>\n);
			if($iframe_profile){
				$line .= qq(<h2>投稿履歴</h2>);
			}
		$line .= qq($history{'index_line'}\n);
		$line .= qq(<div style="$main::kbackground_green1_in$main::kborder_top_in$main::ktextalign_center_in">データ</div>\n);
		$line .= qq(<div>種類： $history{'file_type_japanese'} / 記録開始： $first_how_before ( $first_date ) / 投稿回数： $history{'regist_count'}回</div>\n);
		$line .= qq(<div style="font-size:x-small;color:#080;$main::kborder_top_in$main::kpadding_normal_in">$guide_line</div>\n);

	}

	# ▼デスクトップ版の表示
	else{
		$line .= qq(<div>\n);
		$line .= qq(<h1 id="subject">$h1_text</h1>\n);
		$line .= qq(</div>\n);
			if(!$my_use_device->{'smart_flag'}){
				$line .= qq(<div class="navilinks">$main::backurl_link </div>\n);
			}

			if($iframe_profile){
				$line .= qq($iframe_profile);
				$line .= qq(<h2>投稿履歴</h2>);
			}
		$line .= qq(<div class="history_navigation size90">種類： <span class="red">$history{'file_type_japanese'}</span> │ 記録開始： $first_how_before ( $first_date ) │ 投稿回数： $history{'regist_count'}回</div>\n);
		$line .= qq($history{'index_line'}\n);
		$line .= qq(<div><span class="guide">$guide_line</span></div>\n);
	}


# HTMLを出力
Mebius::Template::gzip_and_print_all({},$line);

exit;

}


1;
