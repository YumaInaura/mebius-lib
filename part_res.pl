
use Mebius::Echeck;
use Mebius::Paint;
use Mebius::Text;
use Mebius::BBS;
use Mebius::BBS::Index;
use strict;

use Mebius::Export;

#-----------------------------------------------------------
# レス投稿
#-----------------------------------------------------------
sub regist_res{

# 宣言
my($type,$thread_number,$new_handle,$new_comment,$new_color,$new_encid,$new_account,$new_res_concept,$image_data) = @_;
my(%type); foreach(split(/\s/,$type)){ $type{$_} = 1; } # 処理タイプを展開
my($bonus_text,$duplication_thread_flag,$thread_link);
my($plustype_duplication,$plustype_news_res,$i_sub,$new_resnumber,$sexvio);
our($head_title,$realmoto,%in,$concept,$int_dir,$doublechecked_flag,$alocal_mode);
our($sub_title,$e_com,$moto,$m_max,$cnumber);
our($enctrip,$host,$date,$title,$head_link3,$head_link4,$subtopic_mode,$k_access,$time);
our($agent,$username,$category);
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

	# 記事ナンバーが指定されていない場合
	if($thread_number eq "" || $thread_number =~ /\D/) { &regist_error("投稿先の記事を指定してください。"); }

# トップデータを取得
my(%thread) = Mebius::BBS::thread({},$realmoto,$thread_number);
our $thread_key = $thread{'concept'};

#kanagawa.ocn.ne.jp

# タイトル、上部メニュー定義
$sub_title = "投稿ページ - $title";
$head_link4 = "&gt; レス投稿";
$head_link3 = qq(&gt; <a href="${thread_number}.html">$thread{'sub'}</a> );


	# 【記事トップデータ】を使っての重複チェック ( すべての文章変換が終わった後に判定すること # && !$alocal_mode && $main::bbs{'concept'} !~ /Local-mode/
	if(!Mebius::Admin::admin_mode_judge() && !Mebius::alocal_judge()){
			if($concept =~ /Light-duplication/){ $plustype_duplication .= qq( Light-judge); }
		($duplication_thread_flag,$thread_link) = Mebius::Text::Duplication("Not-line-check $plustype_duplication",$new_comment,$thread{'lastcomment'});
			if($duplication_thread_flag) {
				Mebius::AccessLog(undef,"Dupulication-bbs-regist","$new_comment\n\n$thread{'lastcomment'}");

				$e_com .= qq(▼ひとつ前のレスと非常に似ているか、文章がそのまま使われています。<br>);
				$e_com .= qq(　<a href="$thread_number.html#S$thread{'res'}">元の記事</a>に戻って確認してください。<br>);
					if($main::myadmin_flag >= 5){ $e_com .= qq(チェック： $duplication_thread_flag<br>); }

			}
	}

	# 現在のチャージ時間をチェック
	if(!Mebius::Admin::admin_mode_judge()){
		require "${int_dir}part_waitcheck.pl";
		my($nowcharge_message) = &get_nowcharge_res("REGIST",$in{'comment'});
		if($nowcharge_message){ $e_com .= $nowcharge_message;  }
	}

	# 次回のチャージ時間を計算
	our($nextcharge_time,$nextcharge_minute,$nextcharge_second,$nextcharge_minsec);
	if(!Mebius::Admin::admin_mode_judge()){
		($nextcharge_time) = &get_nextcharge_res("",$in{'comment'});
		($nextcharge_minute,$nextcharge_second) = &minsec("",$nextcharge_time);
		 $nextcharge_minsec = "$nextcharge_minute分$nextcharge_second秒";
	}

	# おえかき画像の判定
	if($in{'image_session'}){
		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$in{'image_session'});
		if($image{'post_ok'}){ $image_data = qq(1); }
		else{ $e_com .= qq(▼このお絵かき画像は既に投稿済み、もしくは保存期限が切れています。<br$main::xclose>); }
	}

	# エラー/プレビューを表示
	#if(!Mebius::Admin::admin_mode_judge()){
		&error_view("AERROR Target Not-tell","regist_error");
	#}

	# エラー/プレビューを表示
	if(!Mebius::Admin::admin_mode_judge()){
		&error_view("AERROR Target Not-tell","regist_error");
	}

	# アラート突破を記録
	if(!Mebius::Admin::admin_mode_judge() && $main::a_com && $main::alert_type[0]){
		$new_res_concept .= qq( Alert-break-\[$main::alert_type[0]\]);
	}

# ロック開始
Mebius::lock($moto);

# ●スレッドを更新
	# サブ記事の場合
	if(Mebius::BBS::sub_bbs_judge($realmoto)){

		# メイン記事を開いてエラーチェック
		my($main_thread_subject,undef,$main_sexvio) = bbs_thread_for_renew("Flock",$moto,$thread_number);

		# サブ記事を更新
		($i_sub,$new_resnumber,$sexvio) = bbs_thread_for_renew("Renew Sub-thread My-thread",$realmoto,$thread_number,$new_comment,$new_handle,$cnumber,$new_encid,$enctrip,$new_color,$new_account,$image_data,$new_res_concept,"$main_thread_subject &lt;サブ記事&gt;",$main_sexvio);

		# メイン記事を更新 (メイン記事に記録される、サブ記事のレス数を増やす)
		my(%select_renew);
		$select_renew{'sub_thread_res'} = $new_resnumber;
		Mebius::BBS::thread({ Renew => 1 , select_renew => \%select_renew },$moto,$thread_number);

	}
	# メイン記事の場合
	else{
		# メイン記事を更新
		($i_sub,$new_resnumber) = bbs_thread_for_renew("Renew My-thread",$realmoto,$thread_number,$new_comment,$new_handle,$cnumber,$new_encid,$enctrip,$new_color,$new_account,$image_data,$new_res_concept);
	}

	# ●インデックスを更新
	{

		# 追加処理タイプを定義
		my($sort_flag,$sub_thread_flag,%line_control);

		# インデックス中の、該当スレッド行の更新内容を定義
		$line_control{$thread_number}{'last_handle'} = $new_handle;
		$line_control{$thread_number}{'last_res_number'} = $new_resnumber;
		$line_control{$thread_number}{'last_modified'} = time;
			if($thread{'key'} ne "2"){
				$line_control{$thread_number}{'key'} = "1";
			}

			# 記事をアップする判定
			if($concept =~ /AUTO-UPSORT/ || ( $in{'thread_up'} && $concept !~ /NOT-UPSORT/) ) {
				$sort_flag = 1;
			}

			# ▼サブ記事に書き込んだ場合
			if(Mebius::BBS::sub_bbs_judge_auto()){

					Mebius::BBS::index_file({ RegistRes => 1 , Renew => 1 , SubIndex => 1 , line_control => \%line_control },$realmoto);

						# サブ記事への書き込みでも、メインのインデックスをアップする
						if($sort_flag){
							Mebius::BBS::index_file({ Sort => $sort_flag , RegistRes => 1 , Renew => 1 , line_control => { $thread_number => {} } },$moto);
						}

			# ▼メイン記事に書き込んだ場合
			} else {

				my(%select_renew);

					if($main::subtopic_mode){ $sub_thread_flag = 1; }



				# インデックスファイルのトップデータ
				$select_renew{'last_modified'} = time;
				$select_renew{'last_res_thread_number'} = $thread_number;

				Mebius::BBS::index_file({ Sort => $sort_flag , RegistRes => 1 , Renew => 1 , SubThread => $sub_thread_flag , select_renew => \%select_renew , line_control => \%line_control },$moto);

			}

	}

# ロック解除
Mebius::unlock($moto);

	# レスのチャージ時間ファイルを更新
	if(!Mebius::Admin::admin_mode_judge()){
		require "${int_dir}part_waitcheck.pl";
		&renew_nextcharge_res("",$nextcharge_time);
	}

	# サイト全体の新着レスを記録
	if(!Mebius::Admin::admin_mode_judge()){

			if(!$in{'thread_up'} || $main::bbs{'concept'} =~ /Chat-mode/){ $plustype_news_res .= qq( Hidden-from-top); }
		require "${int_dir}part_newlist.pl";
		Mebius::Newlist::threadres("RENEW RES Buffer $plustype_news_res","","","","$realmoto<>$head_title<>$thread_number<>$new_resnumber<>$i_sub<>$new_handle<>$new_comment<>$category<>$new_account<>$new_encid");
	}

	# カテゴリ毎の新着レスを記録
	if(!Mebius::Admin::admin_mode_judge() && $in{'thread_up'} && $main::bbs{'concept'} !~ /Chat-mode/){
		category_newres("",$main::category,$thread_number,$new_resnumber,$i_sub,$new_comment,$new_handle,$sexvio);	
	}


	# サイト全体の今日の投稿数 / 文字数を記録
	if(!Mebius::Admin::admin_mode_judge() && $main::bbs{'concept'} !~ /Chat-mode/){
		renew_reslength();
	}


return($thread_number,$new_resnumber,$i_sub,$new_comment,$new_res_concept,$thread{'posttime'});

}

#-----------------------------------------------------------
# スレッドを更新 / スレッド状態を判定
#-----------------------------------------------------------
sub bbs_thread_for_renew{

# 宣言
my($type,$realmoto,$thread_number,$new_comment,$new_handle,$new_cnumber,$new_encid,$new_trip,$new_color,$new_account,$new_image_data,$new_res_concept,$new_subject,$new_sexvio) = @_;
my(%type); foreach(split(/\s/,$type)){	$type{$_} = 1; } # 処理タイプを展開
my($thread_handler1,@renew_line,$put_age,$other_top_data);

# 日付を取得
my($nowdate) = Mebius::now_date();
my($my_addr) = Mebius::my_addr();

# 記事を定義
my($thread_directory) = Mebius::BBS::path({ Target => "thread_directory" } , $realmoto);
	if(!$thread_directory){ main::error("記事を設定できません。"); }
my $file = "${thread_directory}$thread_number.cgi";

# 記事を開く
my($open) = open($thread_handler1,"+<",$file);

	# 記事を開けなかった場合
	if(!$open){
			# サブ記事の場合は新規作成
			if($type{'Sub-thread'}){
				my	$line = qq(<>$new_subject<>0<>1<><><><><><><><><><><><><><><>\n);
					$line .= qq(0<><><><><><><><><><><>\n);
					Mebius::Mkdir(undef,${thread_directory});
					Mebius::Fileout(undef,$file,$line);
					open($thread_handler1,"+<$file");
			}
			# メイン記事の場合はエラーに
			else{
				regist_error("記事が存在しません。");
			}
	}

	# ファイルロック
	if($type{'Renew'} || $type{'Flock'}){ flock($thread_handler1,2); }

# トップデータを分解
chomp(my $top_thread = <$thread_handler1>);
my($no,$sub,$res,$key,$lasthandle,$last_res_time,$d_delman,$lastmodified,$dd1,$sexvio,$dd3,$dd4,$memo_editor,$memo_body,$dd7,$lock_end_time,$last_comment,$dd10,@other_top_data) = split(/<>/, $top_thread);

# レス数の調整
my $new_resnumber = $res + 1;

	# 多重書き込みを禁止
	if($type{'My-thread'} && $last_res_time == time && $lasthandle eq $new_handle){
		close($thread_handler1);
		Mebius::AccessLog(undef,"Double-res-regist","${main::jak_url}$realmoto.cgi?mode=view&no=$thread_number#S$res");
		regist_error(qq(多重書き込みです。<a href="/_$realmoto/$thread_number.html#S$res" target="_blank" class="blank">元の記事</a>にもう書きこまれていませんか？));
	}

	# 題名がない場合、記事消失とみなす
	if($sub eq ""){
		close($thread_handler1);
		regist_error("題名がないか、記事が消えています。");
	}

	# スレッドのキーチェック
	if($key eq "0" && (!$lock_end_time || $main::time < $lock_end_time)) {
		close($thread_handler1);
		&regist_error("この記事はロックされています。");
	}
	elsif($key == 3) {
		close($thread_handler1);
		&regist_error("この記事は過去ログです。");
	}
	elsif($key == 4 || $key == 6 || $key == 7 || $key eq "") {
		close($thread_handler1);
		&regist_error("この記事は存在しないか、削除済みです。");
	}

	# レスが最大に達している場合
	if($type{'My-thread'} && $res >= $main::m_max) {
		close($thread_handler1);
		&regist_error("レスが最大数 ( $main::m_max件 ) を超えています。もうこの記事には書き込めません。");
	}

	# 携帯からの投稿のみ、ユーザーエージェントを記録
	if($main::k_access || $main::bbs{'concept'} =~ /RECORD-AGENT/){ $put_age = $main::agent; }

	# ファイル更新する場合
	if($type{'Renew'}){

			# サブ記事の調整
			if($type{'Sub-thread'}){
				$sub = $new_subject;
				$sexvio = $new_sexvio;
			}

		# トップデータを追加
	foreach(@other_top_data){
		$other_top_data .= qq($_<>);
	}
	push(@renew_line,"$no<>$sub<>$new_resnumber<>$key<>$new_handle<>$main::time<>$d_delman<>$main::time<>$dd1<>$sexvio<>$dd3<>$dd4<>$memo_editor<>$memo_body<>$dd7<>$lock_end_time<>$new_comment<>$dd10<>" . $other_top_data . qq(\n));

			# ファイルを展開
			while(<$thread_handler1>){

				# 更新行を追加
				push(@renew_line,$_);

			}

		# 新しい行を追加
		push(@renew_line,"$new_resnumber<>$new_cnumber<>$new_handle<>$new_trip<>$new_comment<>$nowdate<>$main::host<>$new_encid<>$new_color<>$put_age<>$main::username<><>$new_account<>$new_image_data<>$new_res_concept<>$main::time<>$my_addr<>\n");

			# ファイルに直接書き込み
			if($type{'Renew'}){
				Mebius::File::truncate_print($thread_handler1,@renew_line);
				#seek($thread_handler1,0,0);
				#truncate($thread_handler1,tell($thread_handler1));
				#print $thread_handler1 @renew_line;
			}
	}


# ファイルクローズ
close($thread_handler1);

# パーミッション変更
Mebius::Chmod(undef,$file);

return($sub,$new_resnumber,$sexvio);

}


#-----------------------------------------------------------
# 投稿数、文字数記録ファイルを更新
#-----------------------------------------------------------
sub renew_reslength{

# 宣言
my(@line,$length,$filehandle);
our($int_dir,$secret_mode,$thisyear,$thismonth,$today,$smlength);

my($now_date_multi) = Mebius::now_date_multi();

	# リターン
	if($secret_mode){ return; }

# ファイル読み込み
open($filehandle,"<","${int_dir}_reslength/${thisyear}_${thismonth}_${today}.cgi");
flock($filehandle,1);
chomp(my $top = <$filehandle>);
my($res,$length,$average,$wday) = split(/<>/,$top);
close($filehandle);

# 追加する行
$res++;
$length += $smlength;
	if($res && $length){ $average = int($length / $res); }
	if($wday eq ""){ $wday = $now_date_multi->{'weekday'}; }
@line = qq($res<>$length<>$average<>$wday<>\n);

# ファイル更新
Mebius::Fileout("MAKE","${int_dir}_reslength/${thisyear}_${thismonth}_${today}.cgi",@line);

}

#-----------------------------------------------------------
# カテゴリ毎の新着レスを記録
#-----------------------------------------------------------
sub category_newres{

# 局所化
my($type,$category,$i_postnumber,$i_resnumber,$i_sub,$i_com,$i_handle,$sexvio) = @_;
my($line,$i);
our($realmoto,$cnumber,$agent);

	# リターン
	if($main::secret_mode){ return; }
	if($main::news_mode eq "0"){ return; }

# 初期キー
my $key = 1;

	# 非表示にする場合
	if($sexvio){ $key = 2; }
	if($i_sub =~ /(性|暴\|グロ|レイプ)/){ $key = 2; }
	if($main::bbs{'concept'} =~ /Sousaku-mode/ && $i_sub =~ /(イジメ|いじめ|虐め|苛め|残酷)/){ $key = 2; }
	if($i_com =~ /あげ/ && $main::smlength < 20){ $key = 2; }

# 追加する行
$line .= qq($key<>$main::realmoto<>$main::title<>$i_postnumber<>$i_sub<>$i_handle<><>$i_resnumber<>$main::time<>$main::date<>$category<>$main::smlength<>$main::pmfile<>$main::cnumber<>$main::agent<>\n);

# ファイル読み込み
open(NEWRES_IN,"<","${main::int_dir}_sinnchaku/_category/${category}_newres.cgi");
	while(<NEWRES_IN>){
		chomp;
		my($key,$moto2,$title2,$no,$sub,$handle,$none,$res,$lasttime,$date2,$category2,$length,$account) = split(/<>/);
			if($moto2 eq $realmoto && $no eq $i_postnumber){ next; }
		$i++;
			if($i <= 10){ $line .= qq($_\n); }
	}
close(NEWRES_IN);

# ファイル更新
Mebius::Fileout(undef,"${main::int_dir}_sinnchaku/_category/${category}_newres.cgi",$line);

}



1;
