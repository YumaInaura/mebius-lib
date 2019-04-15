
use Mebius::Paint;
use Mebius::Echeck;
use Mebius::BBS::Past;
use Mebius::RegistCheck;
package main;


#-----------------------------------------------------------
# 新規投稿
#-----------------------------------------------------------
sub regist_post{

# 宣言
my($basic_init) = Mebius::basic_init();
my($type) = @_;
my($allnum,$sexvio_check,$i,$flag,@new,@tmp,@top,$index_handler,$thread_handler,$past_handler,$plustype_news_thread,@be_old_thread_numbers);
our($realmoto,$head_title,$pmfile,$i_sub,$new_res_concept,%bbs,%in,$cnumber,$i_sub,$nowfile);

	# 通常投稿 (管理者以外)
	if(!Mebius::Admin::admin_mode_judge()){

			# サブ記事専用掲示板の場合、エラー
			if($subtopic_mode){ &regist_error("サブ記事モードでは新規投稿できません。"); }

		# 連続投稿、ペナルティチェック
		require "${int_dir}part_newwaitcheck.pl";
		($newwait_flag,$newwait_dayhourmin,$nextwait_dayhour,$bonusform_flag) = &sum_newwait();
		sum_newwait_penalty();

		# ～時間以内にレスをしていないと、新規投稿できなくする場合
		require "${main::int_dir}part_newform.pl";
		Mebius::BBS::PostAfterResCheck();

		# 新規投稿の内容チェック
		regist_post_check();

		# 新規投稿の内容チェック
		Mebius::Regist::SubjectCheckBBS(undef,$i_sub,$i_com,$main::bbs{'concept'});

		# レス番表記の適正チェック
		#($i_com) = checkres_number($i_com,100);

	}

# ロック開始
&lock($moto);

	# インデックスがない場合は作成する ( $realmoto ではなく $moto を渡す )
	if(!-f $nowfile && Mebius::BBS::bbs_exists_check($moto)){
		my($index_directory_path_per_bbs) = Mebius::BBS::index_directory_path_per_bbs($moto);
		Mebius::mkdir($index_directory_path_per_bbs);
		Mebius::Fileout(undef,$nowfile,"0<><><><>\n");
	}

# 現行インデックスを開く
open($index_handler,"<",$nowfile) || &regist_error("インデックスが開けません。");

# ファイルロック
flock($index_handler,1);

# 掲示板、データトップを読み込み
chomp(my $top = <$index_handler>);
my($new) = split(/<>/,$top);
close($index_handler);

	# 記事消失してる場合、エラー
	if($new eq ""){
		&regist_error("インデックスが消えています。<a href=\"mailto:$basic_init->{'admin_email'}\">管理者</a>まで連絡してください。");
	}

	# 連続投稿エラー テキスト
	if($newwait_flag && !$freepost_mode && !$alocal_mode) {

		if($in{'k'}){$k_find_tag="k";}
		$e_com .= qq(▼新規投稿は、あと <strong class=\"red\">$newwait_dayhourmin</strong> 待って下さい。<a href="${k_find_tag}find.html">記事検索</a>などをして、他の記事を使いましょう。<br>);
		$emd++;
		$strong_emd++;
	}

	# 重複スレッド書き込み禁止
	for(1..25){
		$new++;
		my($thread_file) = Mebius::BBS::thread_file_path($moto,$new);
			# スレッドが存在する場合
			if(-f $thread_file){
				next;
			}
			else{
				$next_thread_ok_flag = 1;
				last;
			}
	}

	# 新しいナンバーの記事がが既にある場合
	if(!$next_thread_ok_flag){
		Mebius::send_email("To-master",undef,"存在する記事ナンバー ($new)","新規投稿がうまくいかなかったみたいです。\n\nhttp://$server_domain/jak/$moto.cgi");
		regist_error("既にこのナンバーの記事は存在します。");
	}

# 汚染チェック
$new =~ s/\D//;
$i_postnumber = $new;

# エラーフラグがある場合、エラーモードへ（その１）
&error_view("AERROR Target Not-tell","regist_error");

	# アラート突破を記録
	if($main::a_com && $main::alert_type){ $new_res_concept .= qq( Alert-break-\[$main::alert_type[0]\]); }

# 現行インデックスを開く
open($index_handler,"<",$nowfile) || &regist_error("インデックスが開けません。");

# ファイルロック
flock($index_handler,1);

# 掲示板、データトップを読み込み
chomp(my $top_buffer = <$index_handler>);

	# 現行インデックスを展開
	while (<$index_handler>) {
		my($thread_number2,$sub,$key) = (split(/<>/))[0,1,6];
		$i++;
			# 記事名重複チェック
			if ($sub eq $in{'sub'}) { $flag++; }
			# 管理者記事は、最上部に保留
			#elsif ($key == 2) { push(@top,$_); next; }
			# 記事数が溢れた場合、過去ログ化
			if ($i >= $i_max) {	
				push(@tmp,$_);
				push(@be_old_thread_numbers,$thread_number2);
			}
			# 平常どおり、ログ追加
			#else { push(@new,$_); }
	}

close($index_handler);

	# 記事名重複チェック
	if($flag) {
		if($alocal_mode){ $i_sub .= qq( - $time); }
		else{ $e_sub .= "▼$in{'sub'}という題名は重複しています。（別の題名を使ってください）<br>"; $emd++; }
	}

# タイトル、上部メニュー定義
$sub_title = "新規投稿 - $title";
$head_link3 = "&gt; 新規投稿フォーム";
$i_resnumber = 0;

	# おえかき画像の判定
	if($in{'image_session'}){
		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$in{'image_session'});
		if($image{'post_ok'}){ $image_data = qq(1); }
		else{ $e_com .= qq(▼このお絵かき画像は既に投稿済み、もしくは保存期限が切れています。<br$main::xclose>); }
	}

# エラーフラグがある場合、エラーモードへ（その２）
error_view("AERROR Target Not-tell","regist_error");

# 新記事、インデックス行のキーを決める
my($index_key);
if($in{'sex'}){ $index_key = 9; }
elsif($in{'vio'}){ $index_key = 8; }
else{ $index_key = 1; }

# ログディレクトリを作成
Mebius::Mkdir(undef,"$main::bbs{'data_directory'}");
Mebius::Mkdir(undef,"$main::bbs{'data_directory'}_index_${moto}");
#Mebius::Mkdir(undef,"$main::bbs{'data_directory'}_thread_log_${realmoto}");

# インデックス更新 ( ファイルロックのため、改めてファイルを開いて書き込む )
my(%select_renew);
$select_renew{'+'}{'thread_num'} = 1;
$select_renew{'last_modified'} = time;
$select_renew{'last_post_time'} = time;
my $new_line = qq($new<>$i_sub<>0<>$i_handle<>$time<>$i_handle<>$index_key<>\n);
Mebius::BBS::index_file({ Renew => 1 , NewThread => 1 , select_renew => \%select_renew , new_line => $new_line , max_line => $i_max } , $moto);

	# ●旧過去ログメニュー ( 検索用ファイル ) を更新
	{
		my $i = 0;
			if(@tmp >= 1) {
				Mebius::BBS::old_type_past_menu_file({ Renew => 1 , bbs_kind => $realmoto ,  add_line => \@tmp , thread_number => $be_old_thread_numbers[$i]} );
				$i++;
			}
	}

	# ●新過去ログを追加
	foreach(@be_old_thread_numbers){
		Mebius::BBS::BePastThread(undef,$main::realmoto,$_);
	}

# 記事主のＸＩＰを記録
if(!$no_xip_action){ $post_xip = "$xip_enc"; }

# 性表現、暴力表現
if($in{'vio'}){ $sexvio_check = 1; }
if($in{'sex'}){ $sexvio_check = 2; }
if($in{'sex'} && $in{'vio'}){ $sexvio_check = 3; }

	# ●スレッド更新
	{

		# トップデータ
		my $select_renew = { concept => $new , sub => $i_sub , lasthandle => $i_handle , res => 0 , key => 1 , sexvio => $sexvio_check , lastmodified => time , lastrestime => time , lastcomment => $i_com , poster_xip => $post_xip , posttime => time };
	
		my $new_line = "0<>$cnumber<>$i_handle<>$enctrip<>$i_com<>$date<>$host<>$encid<>$in{'color'}<>$main::agent<>$username<><>$pmfile<>$image_data<>$new_res_concept<>$main::time<>\n";
		my($renewed) =  Mebius::BBS::thread({ ReturnRef => 1 , Renew => 1 , AllowTouchFile => 1 , new_line => $new_line , select_renew => $select_renew },$moto,$new);


	}

#ＸＩＰファイル生成
regist_post_xip();

# ロック解除
&unlock($moto);


	# サイト全体の新着記事リストを更新
	if($main::bbs{'concept'} =~ /Chat-mode/){ $plustype_news_thread .= qq( Hidden-from-top); }
require "${int_dir}part_newlist.pl";
Mebius::Newlist::threadres("RENEW THREAD $plustype_news_thread","","","","$realmoto<>$head_title<>$i_postnumber<>$i_resnumber<>$i_sub<>$i_handle<>$i_com<>$category<>$pmfile<>$encid");

	# 自動 違反報告
	if(Mebius::Fillter::basic(utf8_return($i_sub),utf8_return($i_com))){
		
	}

#my $subject_utf8 = utf8_return($i_sub);
#$bbs_thread->new_submit({ bbs_kind => $realmoto , thread_number => $i_postnumber , subject => $subject_utf8 });

return($i_postnumber,$i_resnumber,$i_sub);

}

no strict;

#-----------------------------------------------------------
# ＸＩＰファイル生成
#-----------------------------------------------------------
sub regist_post_xip{

# リターン
if($freepost_mode){ return; }

my($share_directory) = Mebius::share_directory_path();

# 書き出し内容を定義
my $nexttime = $time + $new_wait*60*60;
$cnew_time = $nexttime;
my $xip_out = qq($nexttime);

# ＸＩＰファイルを書き出し
Mebius::Fileout(undef,"${share_directory}_ip/_ip_new/${xip_enc}.cgi",$xip_out);

	# 一定の確率で古いＸＩＰファイルを全削除
	if(rand(1000) < 1){ &oldremove("","${share_directory}_ip/_ip_new","30"); }


}

#-----------------------------------------------------------
# 新規投稿時の、題名などの基本チェック
#-----------------------------------------------------------
sub regist_post_check{

# 共通の判定（新規投稿）
if($concept =~ /NOT-POST/) { $e_sub .= "▼この掲示板では新規投稿は出来ません。<br>"; $emd = 1; }
if ($a_access) { $e_sub .= "▼<a href=\"${guide_url}%BD%E0%C5%EA%B9%C6%C0%A9%B8%C2";\">新規投稿の権利がありません</a>。<br>"; $emd = 1; } 
$sub_leng = (length $i_sub); $z_sub_leng = $sub_leng / 2;

if($bbs{'concept'} =~ /Newpost-minimum-message/){ $new_min_msg = 10; }
if ($bglength > $new_max_msg) { $e_com .= "▼文字数が多すぎます 。（全角 $bglength文字/$new_max_msg文字）<br>"; $emd = 1; }
if ($smlength < $new_min_msg && !$alocal_mode) { $e_com .= "▼文字数が少なすぎます。 （全角 $smlength文字/$new_min_msg文字）<br>"; $emd = 1; }

# 性的内容、暴力的内容
&sexvio_postcheck();

	# 創作モード判定（新規投稿 -----
	if($main::bbs{'concept'} =~ /Sousaku-mode/){

			if($category ne "diary"){
			# 創作的な題名の判定（２ / 投稿者名で検索）
			if (index($i_sub,$i_handle) >= 0) { $a_subdeny .= "▼<a href=\"${guide_url}%C1%CF%BA%EE%A4%CE%C2%EA%CC%BE\">題名に”$i_handle（自分の名前）”があるのは、あまりふさわしくありません。</a><br>
			　（作品名や、工夫のあるタイトルを使いましょう）<br>"; }

			if ($i_sub =~ /実話/){
			$e_com .="▼実話小説は問題が大きくなるため、投稿しないでください。あなたや友達の氏名を絶対に書き込まないでください。<br>";  }

			}

	}


# 普通モードの判定（新規投稿）

	else{

		#雑談記事の判定
		if($concept !~ /ZATUDANN-OK/){
				if($i_sub =~ /(暇|男女)/){
						if($i_sub =~ /(語|話)/){
							$e_sub .= qq(▼ただの雑談記事は作れません。<br>);
							$emd++;
						}
				}
		}

			
			#個人的記事の判定（１ / キーワードで判定）
			if ($i_sub =~ /(俺と|僕と|めまして|こんにち)/) { $a_subdeny .= "▼<a href=\"${guide_url}%B8%C4%BF%CD%C5%AA%A4%CA%B5%AD%BB%F6\">個人的な記事を作ろうとしていませんか？</a><br>
			　（利用者全員が使える記事を作りましょう）<br>"; }


			# 個人的記事の判定（２ / 投稿者名で検索）
			if ($i_handle ne "" && index($i_sub,$i_handle) >= 0) {
			$e_sub .= "▼<a href=\"${guide_url}%B8%C4%BF%CD%C5%AA%A4%CA%B5%AD%BB%F6\">題名に、自分の名前”$i_handle”を入れることは出来ません。</a><br>
			　個人的な記事ではなく、一般的な記事を作ってください。<br>"; $emd = 1; }

			# 遊び記事の判定

			if($concept !~ /MODE-ASOBI/){
			@aso_word = ('オーディ','学園','しりとり');
			foreach(@aso_word){ if(index($i_sub,$_) >=0){$tit_aso_flg = 1;} }
			if($tit_aso_flg){$a_sub .="▼<a href=\"${guide_url}%CD%B7%A4%D3%CC%DC%C5%AA%A4%CE%B5%AD%BB%F6\">「しりとり」「ごっこ遊び」など、遊び目的の記事を作ろうとしていませんか？</a><br>
			　（掲示板は、話題を決めて話し合う場所です）<br>";  }
			}

			if ($i_sub =~ /(（性的|エロ|エッチ)/){
			$a_sub .="▼<a href=\"${guide_url}%C0%AD%C5%AA%A1%A2%CB%BD%CE%CF%C5%AA%A4%C7%BB%D7%CE%B8%A4%CE%A4%CA%A4%A4%C5%EA%B9%C6\">単に性的な記事を作ろうとしていませんか？</a><br>
			　（愉快目的だったり、思慮のない記事は作らないでください）<br>"; $amd++; }

			if ($i_sub =~ /(メル|文通|彼氏|彼女|募集|合コン)/) { $a_subdeny .= "▼<a href=\"${guide_url}%A5%CA%A5%F3%A5%D1%B9%D4%B0%D9\">彼氏、彼女、メル友、文通相手の募集などをしていませんか？</a><br>
			　メビウスリングは、出会い系ではありません。<br>"; $amd = 1; }

	}

	# 本文チェック
	foreach(split/<br>/,$i_com){
		if($bbs{'concept'} !~ /(ZATUDANN-OK1|ZATUDANN-OK2)/
					 && $main::category ne "narikiri" && $main::category ne "gokko" 
								&& $_ =~ /プロフ/ && $_ =~ /((書|か)(いて|きます|く))/){
			$e_com .= qq(▼雑談化防止のため、参加者にプロフィールを書かせることはご遠慮ください。<br>);
			Mebius::Echeck::Record("","Post-profile-error");
		}

	}


}

#-----------------------------------------------------------
# 性的な内容、暴力的な内容のチェック
#-----------------------------------------------------------
sub sexvio_postcheck{

my($basic_init) = Mebius::basic_init();

# リターン
if($main::bbs{'concept'} !~ /Sousaku-mode/){ return; }

# 局所化
my($age,$free,$subsex_flag,$vio_flag);

	# 携帯でクッキー認証できない場合
	if($k_access && !$cookie){ $free = 1; }

# 現在の年齢を計算
my($age);
	if($free){ $age = 20; }
	elsif(!$cage){ $age = 0; }
	else{ $age = $thisyear - $cage; }

	# 暴\力的な内容
	if($in{'vio'} && $age < 15){
		$e_sub .= qq(▼<a href="$basic_init->{'main_url'}?mode=settings#EDIT">暴\力的な内容を含む場合は、マイページで年齢設定をしてください（15歳未満不可）。</a><br>); $emd++;
	}

	elsif($i_sub =~ /(グロ|\(暴\|（暴\|暴\力|イジメ|いじめ|いぢめ|殺人|虐め|苛め|残酷|微暴\|暴\アリ|暴\あり)/){
			if($age < 15){ $e_sub .= qq(▼<a href="$basic_init->{'main_url'}?mode=settings#EDIT">暴\力的な内容を含む場合は、マイページで年齢設定をしてください（15歳未満不可）。</a><br>); $emd++; }
			else{ $e_sub .= qq(▼「暴\力的な投稿」のルールが変わりました。題名には注意書きを入れず、投稿フォームの専用チェックボックスをオンにしてください。</a><br>); $emd++; }
	}

	# 暴力 - 本文
	if($i_com =~ /(グロ|いじめ|イジメ|殺人|暴\行|虐め|苛め|残酷)/ && !$in{'vio'}){ $a_com = qq(▼もし暴\力的な内容を含む場合は、投稿フォームの専用チェックボックスをオンにしてください(15歳未満不可)。<br>); $amd++; }

	# 性表現チェック - 題名
	if($i_sub =~ /(性的|微性|\激性|\(性|（性|性\)|性）)/ || $i_sub =~ /(Ｒ|R)/ && $i_sub =~ /(18|１８|禁)/ || $i_sub =~ /性/ && $i_sub =~ /(ＢＬ|BL|ＧＬ|GL)/ || ($i_sub =~ /性/ && $i_sub =~ /暴\/)){ $subsex_flag = 1; }

	if($subsex_flag){$e_sub .= qq(▼「性的な投稿」のルールが変わりました。題名には注意書きを入れず、投稿フォームの専用チェックボックスをオンにしてください(18歳未満不可)。</a><br>); $emd++; }

	if($in{'sex'} && !$age){ $e_sub .= qq(▼<a href="$basic_init->{'main_url'}?mode=settings#EDIT">性的な内容を含む場合は、マイページで年齢設定をしてください（18歳未満不可）。</a><br>); $emd++; }
	elsif($in{'sex'} && $age < 18){ $e_sub .= qq(▼<a href="$guide_url\%C0%AD%C5%AA%A4%CA%C9%BD%B8%BD">18才未満の方は、性的内容を含む記事を作れません。</a><br>); $emd++; }

	# 性表現チェック - 本文
	if($i_com =~ /(性的)/ && !$in{'sex'}){
		if(!$age){
		$a_com = qq(▼<a href="$basic_init->{'main_url'}?mode=settings#EDIT">性表\現が含まれる場合、マイページで年齢設定を済ませてください(18歳以上)。</a>。<br>);
		}
		elsif($age >= 18){
		$a_com = qq(▼性表\現がある場合、適切なチェックを入れてください（投稿フォーム下）。<br>);
		}
		else{
		$a_com = qq(▼18歳以下の場合、性表\現を含む記事を作ってはいけません。<br>);
		}
		$amd++;
	}

}



1;
