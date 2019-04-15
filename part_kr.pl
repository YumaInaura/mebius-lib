
use strict;
use Mebius::BBS;
use Mebius::Getpage;
use Mebius::Getstatus;
package main;
use Mebius::Export;

#-----------------------------------------------------------
# 処理開始 - strict
#-----------------------------------------------------------
sub open_kr{

# 宣言
my($type,$moto,$kr_number,$sub) = @_;
my(undef,$account) = @_ if($type =~ /Account/);
my($set_no,$set_moto,$set_sub,$set_domain,$domain);
our(%in,$moto,$bot_access,$concept,$myadmin_flag,$alocal_mode,$crireki,$server_domain,$cview,$no_headerset);
our($secret_mode,$int_dir,$realmoto);

	# 各種リターン
	if($concept =~ /NOT-KR/){ return; }
	if($secret_mode){ return; }
	if($myadmin_flag && !$alocal_mode && $main::bbs{'concept'} !~ /Local-mode/){ return; }
	if($bot_access){ return; }

	# ●閲覧履歴から登録する場合
	if($type =~ /VIEW/ && $ENV{'REQUEST_METHOD'} eq "GET"){

		# 局所化
		my($cview_buf,$domain);

		# 新しい閲覧履歴のCookie をセット ( $cview がなくても Cookie はセット、しかし登録せずにリターン )（掲示板用）
		($cview,$cview_buf) = ("$kr_number<A>$moto<A>$sub<A>$server_domain",$cview);

		Mebius::Cookie::set_main({ last_view_thread => $cview });

			# $cview が無かった場合、Cookieセット後にリターン
			if(!$cview_buf){ return; }

		# 現在のCookie ( $cview_buf ) を分解
		($set_no,$set_moto,$set_sub,$set_domain) = split (/&lt;A&gt;/,$cview_buf);
		
	}

	# ●投稿履歴から登録する場合
	elsif($type =~ /REGIST/){
		require "${int_dir}part_history.pl";
		($set_no,$set_moto,$set_sub,$set_domain) = &get_reshistory("KRCHAIN My-file",undef,undef,"<>$kr_number<><>$realmoto<><>$server_domain<>");
	}

# 関連記事の登録処理へ
related_thread("Renew BBS",$moto,$kr_number,$set_domain,$set_moto,$set_no,$set_sub);

}

#-----------------------------------------------------------
# 関連記事ファイル作成
#-----------------------------------------------------------
sub related_thread{

# 宣言
# $kr_number → 関連記事ファイル / $set_domain - $set_moto - $set_no → 関連記事内に登録する記事
my($type,$kr_moto,$kr_number,$set_domain,$set_moto,$set_no,$set_sub) = @_;
my(undef,$account) = @_ if($type =~ /Account/);
my(undef,undef,undef,$maxview) = @_ if($type =~ /(Index|Oneline)/);
my(@renewline,%th,$i,$redun_flag,$kr_handler,$allowdomain_flag,$krfile,$one_line,$sflag,$index_line,$renew_flag,$rand_delete,$krurl,$maxline_renew);
my($flow_flag,$krdirectory);
our($int_dir,$logpms,$server_domain,@domains,$script,%in,$auth_url,$xclose);

	# ランダム削除の確率を決める（以後のループ内での定義はしない。全体で一律の確率とする）
	if($type =~ /Renew/){ $rand_delete = rand(15); }

	# ファイル定義（アカウントへの登録用）
	if($type =~ /Account/){
		$account =~ s/[^0-9a-zA-Z]//g;
			if($account eq ""){ return(); }
		my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
		$krdirectory = "${auth_log_directory}_kr_auth/";
		$krfile = "${krdirectory}${account}_kr.log";
		#$krfile = "${account_directory}${account}_kr.log";
		$krurl = "$auth_url$account/";
	}

	# ファイル定義（掲示板への登録用）
	else{
		$kr_moto =~ s/\W//g;
		$kr_number =~ s/\D//g;
			if($kr_moto eq ""){ return(); }
			if($kr_number eq ""){ return(); }
		$krdirectory = "$main::bbs{'data_directory'}_kr_$kr_moto/";
		$krfile = "${krdirectory}${kr_number}_kr.cgi";
		$krurl = "http://$server_domain/_$kr_moto/$kr_number.html";
	}


	# 最大表示行数を代入
	if($type =~ /Oneline/){
		if(!$maxview){ $maxview = 5; }
	}

	# 最大表示行数を代入
	if($type =~ /Index/){
		if(!$maxview){ $maxview = 100; }
	}


	# ★ファイル更新する場合
	if($type =~ /Renew/){

			# 正規ドメインかどうかをチェック
			foreach(@domains){
				if($set_domain eq $_){ $allowdomain_flag = 1; }
			}
			if(!$allowdomain_flag){ return(); }

		# これから登録する記事の各種値をチェック
		$set_moto =~ s/\W//g;
		$set_no =~ s/\D//g;
		if($set_moto =~ /^(sc|sub)/){ return(); }
		if($set_moto =~ /^(cha|ckj|csh|ccu|cnr)$/){ return(); }
		if($set_moto eq "delete"){ return(); }
		if($set_moto eq ""){ return(); }
		if($set_no eq ""){ return; }

		# 自分（の記事）に自分（の記事）を登録しようとしている場合はリターン(掲示板用ではあり得ない)
		if($type =~ /BBS/ && $set_moto eq $kr_moto && $set_no == $kr_number){ return; }

			# サーバーが同じ場合、ログファイルから元ファイルのリンク切れチェック
			if($server_domain eq $set_domain){

				(%th) = Mebius::BBS::thread({},$set_moto,$set_no);
					if($th{'keylevel'} < 1){ return(); }
			}

			# サーバーが違う場合、ステータスコードからリンク切れをチェック
			else{
				my($status) = Mebius::Getstatus("","http://$set_domain/_$set_moto/$set_no.html");
				if($status ne "200"){ return(); }
			}

	}

	# ★関連記事ファイルを開く
	open($kr_handler,"<$krfile");

		# ファイルロック
		if($type =~ /Renew/){ flock($kr_handler,1); }

		# ファイルを展開する
		while(<$kr_handler>){

			# ループカウンタ
			$i++;

			# この行を分解
			chomp;
			my($no2,$moto2,$sub2,$domain2,$num2,$lasttime2) = split (/<>/);

				# ドメイン指定番号から実ドメインを復元（旧記録への対応）
				if($domain2 eq "2"){ $domain2 = "mb2.jp"; }
				elsif($domain2 eq "1"){ $domain2 = "aurasoul.mb2.jp"; }

				# 秘密板、データ壊れなどをエスケープ 
				if($moto2 =~ /(^sc)/){ main::access_log("Secret-kr","ファイル： $krurl"); next; }
				if($moto2 eq "delete"){ next; }
				if($moto2 =~ /^(cha|ckj|csh|ccu|cnr)$/){ next; } # 隠しカテゴリをエスケープ
				if($no2 !~ /^([0-9]+)$/ || $sub2 eq ""){ main::access_log("Broken-kr","ファイル： $krurl / 記事番 $no2 / 題名 $sub2"); next; }

				# ●１行表示取得用
				if($type =~ /Oneline/ && !Mebius::Fillter::basic(utf8_return($sub2))){

						# ポイントがマイナスで非表示の行
						if($num2 < 0 && $type !~ /Editor/){ next; }

						# 最大行数に達した場合
						if($i > $maxview){ $flow_flag =1; last; }

					# １行表示行を追加
					$one_line .= qq(<a href="http://$domain2/_$moto2/$no2.html">$sub2</a>　);

				}

				# ●インデックス取得用
				elsif($type =~ /Index/ && !Mebius::Fillter::basic(utf8_return($sub2))){

						# ポイントがマイナスで非表示の行
						if($num2 < 0 && $type !~ /Editor/){ next; }

						# 最大行数に達した場合
						if($i > $maxview){ $flow_flag = 1; last; }

						# 整形
						$index_line .= qq(<li>);

						# 編集用のリンク
						if($type =~ /Editor/){
							$index_line .= qq( <input type="text" name="${domain2}-${moto2}-${no2}" value="$num2" size="1"$xclose>);
						}


					# 関連記事リンク本体
					$index_line .= qq( <a href="http://$domain2/_$moto2/$no2.html">$sub2</a> ($num2));

					# 整形
					$index_line .= qq(</li>);

				}

				# ●ファイル編集用
				elsif($type =~ /Edit-data/){

						# 大文字を小文字に
						use Mebius::Text;

						# 編集情報を展開
						foreach(keys %main::in){
							my $key = $_;
							my $value = $main::in{$_};
								if($key eq "$domain2-$moto2-$no2"){
										($value) = Mebius::Number("",$value);
										if($num2 ne $value && $value =~ /^(-)?([0-9]{1,8})$/){ $num2 = $value; $renew_flag = 1; }
								}
						}

					# 更新行を追加する
					push(@renewline,"$no2<>$moto2<>$sub2<>$domain2<>$num2<>$lasttime2<>\n");
				}

				# ●ファイル更新用
				elsif($type =~ /Renew/){

						# 記録する最大行数を定義
						my($maxline_renew);
						if($type =~ /Account/){ $maxline_renew = 30; } else { $maxline_renew = 15; }

						# 一定確率で、一定数以上の記事は削除する ( 非表示の記事はエスケープ )
						if((rand($rand_delete) < 1 || $main::alocal_mode) && $i > $maxline_renew && $num2 >= 0){ next; }

						# 同じ記事の場合、元ポイントがマイナスでなければ、関連ポイントを増やす
						if($no2 == $set_no && $moto2 eq $set_moto && $domain2 eq $set_domain){
							if($num2 >= 0 && $main::time >= $lasttime2 + 5*60){ $num2++; $lasttime2 = $main::time; }
							$redun_flag = 1;
						}

						# 間違い登録(自分記事の登録)を削除
						if($moto2 eq $kr_moto && $no2 == $kr_number){ &access_log("KR-SELF"); next; }

					# 更新行を追加する
					push(@renewline,"$no2<>$moto2<>$sub2<>$domain2<>$num2<>$lasttime2<>\n");
				}
		}
	close($kr_handler);

	# ▼インデックス取得後の処理
	if($type =~ /Oneline/){

		# リターン
		return($one_line,$flow_flag);
	}

	# ▼インデックス取得後の処理
	elsif($type =~ /Index/){

		# 整形
		if($index_line){ $index_line = qq(<ul>$index_line</ul>); }

		# リターン
		return($index_line,$flow_flag);
	}


	# ▼ファイル更新後の処理
	elsif( $type =~ /Renew/ || ($type =~ /Edit-data/ && $renew_flag) ){

			# 重複行がなかった場合
			if($type =~ /Renew/ && !$redun_flag){

				# タイトルがない場合は取得する
				if($set_sub eq ""){
					($set_sub) = Mebius::getpage("Title","http://$set_domain/_$set_moto/$set_no.html");
					($set_sub) = split(/ \| /,$set_sub);
					$set_sub =~ s/(\r|\n|\s+$)//g;
				}

				# 新しい行を追加
				unshift(@renewline,"$set_no<>$set_moto<>$set_sub<>$set_domain<>0<>$main::time<>\n");

			}

		# 配列をソート
		@renewline = sort { (split(/<>/,$b))[4] <=> (split(/<>/,$a))[4] } @renewline;

		# ディレクトリを作成
		Mebius::Mkdir(undef,$krdirectory);

		# 関連記事ファイルを更新
		Mebius::Fileout("",$krfile,@renewline);

		# 登録成功のログを記録
		#main::access_log("Kr-Successed","登録先： $krurl 登録元： http://$set_domain/_$set_moto/$set_no.html ( $type )");

		# リターン
		return(1);
	}

}


1;
