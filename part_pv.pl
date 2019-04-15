
use strict;
use Mebius::BBS;
package main;

#-----------------------------------------------------------
# 掲示板の記事カウンタ
#-----------------------------------------------------------
sub do_pv{

# 宣言
my($use,$thread_number,$moto) = @_;
my(@renew_line,$i,$notcount_flag,$scount,$sflag,$scounted_flag,$counted_flag,$all_count,$backup_handler,%self,$FILE1);
my $time = time;
our($agent,$myadmin_flag,$int_dir,$bot_access,$xip,$cookie,$k_access);

	# ファイル / ディレクトリ定義
	if($thread_number eq "" || $thread_number =~ /\D/){ return(); }
	if($moto eq "" || $moto =~ /\W/){ return(); }
my($bbs_file) = Mebius::BBS::InitFileName(undef,$moto);
	if(!$bbs_file->{'data_directory'}){ return(); }

# ファイル定義
my $directory = $self{'directory'} = "$bbs_file->{'data_directory'}_pv_${moto}/";
my $file1 = $self{'file1'} = "$self{'directory'}${thread_number}_pv.cgi";
my $backup_file = "$self{'directory'}${thread_number}_pvbk.cgi";

	# ディレクトリを作成 ( 負荷軽減のため、このあとの処理で、新規ファイル作成時に一緒に処理する )
	#if($use->{'TypeRenew'} && rand(100) < 1){ Mebius::Mkdir("",$directory); }

	# ファイルを開く
	if($use->{'TypeFileCheckError'}){
		$self{'f'} = open($FILE1,"+<",$file1) || main::error("ファイルが存在しません。");
	}
	else{

		$self{'f'} = open($FILE1,"+<",$file1);

			# ファイルが存在しない場合
			if(!$self{'f'}){
					# 新規作成
					if($use->{'TypeRenew'}){
						Mebius::Mkdir(undef,$directory);
						Mebius::Fileout("Allow-empty",$file1);
						$self{'file_touch_flag'} = 1;
						$self{'f'} = open($FILE1,"+<",$file1);
					}
					else{
						return(\%self);
					}
			}

	}

	# ファイルロック
	if($use->{'TypeRenew'} || $use->{'TypeFlock'}){ flock($FILE1,2); }

# トップデータを分解
chomp(my $top = <$FILE1>);
my($count,$scount,$lasttime) = split(/<>/,$top);

	# ファイルを展開
	while(<$FILE1>){

		# ラウンドカウンタ
		$i++;

		# 行を分解
		chomp;
		my($xip2,$lasttime2) = split(/<>/);

			# 以前の記録から◯時間以上経過している場合
			if(time >= $lasttime2 + 24*60*60){ next; }

			# 重複カウントを発見した場合
			if($xip2 eq $xip && !Mebius::alocal_judge()){
				$notcount_flag = 1;
				next;
			}

			# 更新用に行を追加
			push(@renew_line,"$xip2<>$lasttime2<>\n");

	}

# 調整
if($ENV{'HTTP_REFERER'} =~ /http:\/\/(www\.)?(google\.|ping\.|yahoo\.)([a-z]{2,})/ && $ENV{'HTTP_REFERER'} =~ /search\?/){ $sflag = 1; }
if(!$count){ $count = 0; }
$all_count = $count + $scount;

	# カウント数だけ記憶してリターンする場合を定義
	#if($lasttime + 1*60 > time){ $notcount_flag = 1; }				# 前回のカウントから一定時間が【経過していない】場合
	#if($lasttime + 24*60*60 < time){ $notcount_flag = 0; }			# 前回のカウントから一定時間以上【経過している場合は】、無条件にカウントする
	if($myadmin_flag >= 5){ $notcount_flag = 1; }					# 管理者のアクセス
	if(Mebius::alocal_judge()){ $notcount_flag = 0; }					# ローカルモード
	if($bot_access){ $notcount_flag = 1; }											# ボット対策 (この処理は他より後方に配置)
	if(!$agent || (!$k_access && !$cookie && !$sflag) ){ $notcount_flag = 1; }		# ボット対策 (この処理は他より後方に配置)

	# カウントせずに帰る場合
	if($notcount_flag){
		close($FILE1);
			if($main::bbs{'concept'} =~ /NOT-PV/){ return(); }
			else{ return($all_count); }
	}

	# カウント数がない場合、バックアップから読み込み
	#if(!$count){
	#	open($backup_handler,"<",$backup_file);
	#	my $top = <$backup_handler>; chomp $top;
	#	($count,$scount) = split(/<>/,$top);
	#	close($backup_handler);
	#}

# カウント増加
if($sflag){ $all_count++;  $scount++; $scounted_flag = 1; } else { $all_count++; $count++; $counted_flag = 1; }

# 新しく追加する行
unshift(@renew_line,"$xip<>$time<>\n");

# トップデータを追加
unshift(@renew_line,"$count<>$scount<>$time<>\n");

	# ファイル更新
	if($use->{'TypeRenew'}){
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renew_line;
	}

close($FILE1);

	# パーミッション変更
	if($use->{'TypeRenew'} && ($self{'file_touch_flag'} || rand(25) < 1)){ Mebius::Chmod(undef,$file1); }

	#if($use->{'TypeRenew'}){
	#	Mebius::BBS::ThreadStatus->update_table({ update => { access_count => $count , bbs_kind => $moto , thread_number => $thread_number } } );
	#}

	## キリの良い数字でバックアップ
	#if($all_count % 25 == 0 && $all_count >= 25){
	#	my $line = qq($count<>$scount<>\n);
	#	Mebius::Fileout(undef,$backup_file,$line);
	#}

	# ランキングに登録する場合
	if($use->{'TypeAddRanking'}){

		my $count_pace = 50;		# ～PVごとにランキングに登録(普通)
		my $scount_pace = 50;		#  ～PVごとにランキングに登録(検索エンジン)
		my $bbs_count_pace = 10;	#  ～PVごとにランキングに登録(掲示板毎)
		my $count_border = 100;		# ～PV以上でランキングに登録(普通)
		my $scount_border = 100;	# ～PV以上でランキングに登録(検索エンジン)
		my $bbs_count_border = 50;	# ～PV以上でランキングに登録(掲示板毎)
			if(Mebius::alocal_judge()){
				($count_pace,$scount_pace,$count_border,$scount_border,$bbs_count_pace,$bbs_count_border) = (1,1,1,1,1,1);
			}

			if($counted_flag && $all_count >= $count_border && $all_count % $count_pace == 0){
				&renew_pvranking("Renew Normal-count",$all_count,$thread_number,$moto); 
			}
			if($scounted_flag && $scount >= $scount_border && $scount % $scount_pace == 0){
				&renew_pvranking("Renew Search-engine-count",$scount,$thread_number,$moto);
			}
			if($counted_flag && $all_count >= $bbs_count_border && $all_count % $bbs_count_pace == 0){
				&renew_bbs_pvranking("Renew",$all_count,$thread_number,$moto);
			}
	}

	# カウンタの数字は返さずにリターン ( カウント処理はするが、表には出さない場合 )
	if($main::bbs{'concept'} =~ /NOT-PV/){ return(); }
	# 普通にリターン
	else{ return($all_count); }


}


#-----------------------------------------------------------
# ＰＶランキングを更新(サイト全体)
#-----------------------------------------------------------
sub renew_pvranking{

# 宣言
my($type,$count,$thread_number,$moto) = @_;
my(@renew_line,$i,$key,$put_moto,$file,$all_ranking_handler,$keep_min_count,$still_flag);

# 汚染チェック
if($moto =~ /\W/ || $moto eq ""){ return(); }
if($thread_number =~ /\D/ || $thread_number eq ""){ return(); }

# ファイル定義
if($type =~ /Normal-count/){ $file = "rank_pv"; }
elsif($type =~ /Search-engine-count/){ $file = "rank_spv"; }
else{ return; }

# 最大登録行数
my $max_line = 500;

# 各種リターン
if(($main::bbs{'concept'} =~ /NOT-PV/ || $main::secret_mode) && !Mebius::alocal_judge()){ return; }

# 元記事チェック
my(%thread) = Mebius::BBS::thread({},$moto,$thread_number);

# 初期キー
$key = 1;

# 記事内容によっては記録しない
if($thread{'keylevel'} < 0.5){ return(); }
if($thread{'sexvio'}){ return; }
if($thread{'subject'} =~ /(性|暴\|グロ)/){ return; }
if($main::bbs{'concept'} =~ /Sousaku-mode/ && $thread{'subject'} =~ /(イジメ|いじめ|虐め|苛め|残酷)/){ return; }

# ファイル読み込み
open($all_ranking_handler,"<${main::int_dir}_sinnchaku/$file.log");

	# ファイルロック
	if($type =~ /Renew/){ flock($all_ranking_handler,1); }

# トップデータを分解
chomp(my $top1 = <$all_ranking_handler>);
my($tkey,$tmin_count,$ti) = split(/<>/,$top1);

	# 登録数がマックスで、新規記事のカウント数が既存記事のどれにも及ばない場合、すぐにリターン（負荷軽減）
	if($ti >= $max_line && $count <= $tmin_count){
		close($all_ranking_handler);
		return();
	}

	# ファイルを展開
	while(<$all_ranking_handler>){

		# ラウンドカウンタ
		$i++;

		# 行を分解
		chomp;
		my($key2,$count2,$svmoto,$svtitle,$svno,$sub2) = split(/<>/);

		# 最小カウント数を記憶
		if($type =~ /Renew/){
				if($keep_min_count > $count2 || $keep_min_count eq ""){ $keep_min_count = $count2; }
		}

			# 各種ネクスト
			if($i > $max_line){ next; }

			# 同じ記事がある場合
			if($svmoto eq $moto && $svno eq $thread_number){
				$still_flag = 1;
				$count2 = $count;
				$sub2 = $thread{'subject'};
			}

		# 更新行を追加
		if($type =~ /Renew/){
			push(@renew_line,"$key2<>$count2<>$svmoto<>$svtitle<>$svno<>$sub2<>\n");
		}
	}

close($all_ranking_handler);


	# ●ファイル更新する場合
	if($type =~ /Renew/){

			# 新しく追加する行
			if(!$still_flag){
				$i++;
				unshift(@renew_line,"$key<>$count<>$moto<>$main::title<>$thread_number<>$thread{'subject'}<>\n");
			}

		# PVが多い順にソート
		@renew_line = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renew_line;

		# トップデータを追加する
		unshift(@renew_line,"$tkey<>$tmin_count<>$i<>\n");

		# ファイル更新
		Mebius::Fileout(undef,"${main::int_dir}_sinnchaku/$file.log",@renew_line);
	}


}


#-----------------------------------------------------------
# ＰＶランキングを更新(掲示板毎)
#-----------------------------------------------------------
sub renew_bbs_pvranking{

# 宣言
my($type,$count,$thread_number,$moto) = @_;
my($i,$file,$ranking_handler,@renew_line,$top1,$directory,$flow_flag,$keep_min_count,$still_flag);

# 汚染チェック
if($moto =~ /\W/ || $moto eq ""){ return(); }
if($thread_number =~ /\D/ || $thread_number eq ""){ return(); }

# 各種リターン
if(($main::bbs{'concept'} =~ /NOT-PV/ || $main::secret_mode) && !Mebius::alocal_judge()){ return; }

# 元記事チェック
my(%thread) = Mebius::BBS::thread({},$moto,$thread_number);

# 最大登録数
my $max_line = 100;

# ファイル定義
$directory = "$main::bbs{'data_directory'}_other_${moto}/";
$file = "${directory}pvall_${moto}.log";

# 各種チェック
if($thread{'keylevel'} < 0.5){ return(); }
if($thread{'sexvio'}){ return(); }
if($thread{'subject'} =~ /(性|暴\|グロ)/){ return(); }
if($main::bbs{'concept'} =~ /Sousaku-mode/ && $thread{'subject'} =~ /(イジメ|いじめ|虐め|苛め|残酷)/){ return(); }

# ファイル読み込み
open($ranking_handler,"<$file");

# ファイルロック
if($type =~ /Renew/){ flock($ranking_handler,1); }

# トップデータを分解
chomp(my $top1 = <$ranking_handler>);
my($tkey,$tmin_count,$ti) = split(/<>/,$top1);

	# 登録数がマックスで、新規記事のカウント数が既存記事のどれにも及ばない場合、すぐにリターン（負荷軽減）
	if($ti >= $max_line && $count <= $tmin_count){
		close($ranking_handler);
		return();
	}

	# ファイルを展開
	while(<$ranking_handler>){

		# ラウンドカウンタ
		$i++;

		# 行を分解
		chomp;
		my($number2,$subject2,$count2,$post_handle2,$lasttime2,$last_handle2,$key2) = split(/<>/);

		# 最小カウント数を記憶
		if($type =~ /Renew/){
				if($keep_min_count > $count2 || $keep_min_count eq ""){ $keep_min_count = $count2; }
		}

			if($i > $max_line){
				$flow_flag = 1;
				next;
			}
			# 同じ記事の場合
			if($number2 eq $thread_number){
				$still_flag = 1;
				$count2 = $count;
			}
		push(@renew_line,"$number2<>$subject2<>$count2<>$post_handle2<>$lasttime2<><>$key2<>\n");
	}

close($ranking_handler);

	# ●ランキング入り出来た場合、ファイルを更新
	if($type =~ /Renew/){

			# 新しく追加する行
			if(!$still_flag){ push(@renew_line,"$thread_number<>$thread{'subject'}<>$count<>$thread{'posthandle'}<>$main::time<>$thread{'key'}<>\n"); }

		# PVが多い順にソート
		@renew_line = sort { (split(/<>/,$b))[2] <=> (split(/<>/,$a))[2] } @renew_line;

		# トップデータを追加
		if($keep_min_count){ $tmin_count = $keep_min_count; }
		unshift(@renew_line,"1<>$tmin_count<>$i<>\n");

		# 基本ディレクトリ作成
		Mebius::Mkdir(undef,$directory);

		# ファイル更新
		Mebius::Fileout(undef,$file,@renew_line);

	}

}


1;


