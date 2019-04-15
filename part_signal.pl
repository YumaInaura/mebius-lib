
#-----------------------------------------------------------
# 注目データを更新
#-----------------------------------------------------------

sub renew_signal{

# 局所化
my($type,$moto,$category,$num,$res) = @_;
my(@line,$i,$flag,$newkey,$block_flag,$file,$category_hit);

# 権限チェック
if($main::device{'level'} < 1){ $block_flag = qq(この環境では実行できません。); }

# モバイルアイテム取得
if($type =~ /MOBILE/){ &kget_items; }

# ファイル定義
$moto =~ s/\W//;
$category =~ s/\W//;
if($moto eq "" || $category eq ""){ $block_flag = qq(値を指定してください。); }

# 処理タイプ定義
if($type =~ /SIGNAL/){ $file = "${int_dir}_sinnchaku/peta_signal.cgi"; }
elsif($type =~ /RES/){ $file = "${int_dir}_sinnchaku/peta_res.cgi"; }
elsif($type =~ /POST/){ $file = "${int_dir}_sinnchaku/peta_post.cgi"; }
else{ $block_flag = qq(実行タイプを指定してください。); }

# リターンとエラー
if($moto eq "delete" || $secret_mode || $main::bbs{'concept'} =~ /Chat-mode/ || $subtopic_mode){ $block_flag = qq(この掲示板では実行できません。); }
if($home eq "http://mb2.jp/" && $server_domain eq "aurasoul.mb2.jp"){ $block_flag = qq(この掲示板では実行できません。); }
if($block_flag && $type =~ /SIGNAL/){ &error("$block_flag"); }
elsif($block_flag){ return; }

# 連続送信禁止
if($type =~ /SIGNAL/){ &redun("SIGNAL",60); }

# キー定義
$newkey = 1;

# 追加する行
push(@line,"$newkey<>$moto<>$time<>$category<>$num<>$res<>\n"); $category_hit++;

# ファイルを開く
open(FILE_IN,"$file");
while(<FILE_IN>){
$i++;
chomp;
my($key,$moto2,$lasttime,$category2) = split(/<>/);
if($i > 10){ last; }
if($moto2 eq $moto){ next; }
if($category2 eq $category){ $category_hit++; if($category_hit > 3){ next; } }
push(@line,"$_\n");
}
close(FILE_IN);

# ファイルを更新
open(FILE_OUT,">$file");
print FILE_OUT @line;
close(FILE_OUT);
Mebius::Chmod(undef,"$file");

	# モード
	if($type =~ /RES/ || $type =~ /POST/){ return; }


# 終了
exit;


}


#-----------------------------------------------------------
# 注目データを取得
#-----------------------------------------------------------
sub get_signal{

my($line,$type) = @_;
my($hit,$class,$class2,$max,$file,$keeptime);

	# モバイルアイテム取得
	if($type =~ /MOBILE/){ &kget_items; }

	# タイプ処理
	if($type =~ /SIGNAL/){
		$class = qq( class="signal");
		$file = "${int_dir}_sinnchaku/peta_signal.cgi";
		$max = 1;
		$keeptime = 24*60*60;
	}

	# タイプ処理
	if($type =~ /RES/){
		$class = qq( class="star1");
		$file = "${int_dir}_sinnchaku/peta_res.cgi";
		$max = 4;
		$keeptime = 1*60*60;
	}

	# タイプ処理
	if($type =~ /POST/){
		$class = qq( class="star4");
		$file = "${int_dir}_sinnchaku/peta_post.cgi";
		$max = 2;
		$keeptime = 12*60*60;
	}

	if($type =~ /MOBILE/){ }
	else{ $class2 = qq( class="star3"); }

# ファイルを開く
open(FILE_IN,"<$file");
	while(<FILE_IN>){
		chomp;
		my($key,$moto2,$lasttime,$category2,$num,$res) = split(/<>/);
		my($icon);

			if($time > $lasttime + $keeptime){ next; }

			# アイコン
			if($type =~ /SIGNAL/){
					if($type =~ /MOBILE/){ $icon = qq(<span style="color:#080;font-size:small;">★</span>); }
					else{ $icon = qq( <img src="/pct/star_signal.gif" alt="シグナル">); }
			}

			# アイコン
			if($type =~ /RES/){
					if($type =~ /MOBILE/){ $icon = qq(<span style="color:#f00;font-size:small;">★</span>); }
					else{ $icon = qq( <span class="res_star">★</span>); }
					#else{ $icon = qq( <a href="_$moto2/$num.html#S$res" class="res_star">★</a>); }
			}

			# アイコン
			if($type =~ /POST/){
					if($type =~ /MOBILE/){ $icon = qq(<span style="color:#f00;font-size:small;">★★</span>); }
					else{ $icon = qq( <span class="post_star">★★</span>); }
					#else{ $icon = qq( <a href="_$moto2/$num.html" class="post_star">★★</a>); }
			}

		#if($max >= 5 && $hit >= $max*0.5){ $line =~ s/<a href="_$moto2\/">(.+?)<\/a>/<a href="_$moto2\/"$class2>$1<\/a>/g; }

		$line =~ s/<a href="_$moto2\/">(.+?)<\/a>/<a href="_$moto2\/"$class>$1<\/a>$icon/g;

		$hit++;

			if($hit >= $max){ last; }


	}
close(FILE_IN);

return($line);

}


1;

