
#-----------------------------------------------------------
# 削除処理
#-----------------------------------------------------------
sub do_oldremove{

# 宣言
my($type,$directory,$unlink_time,$random) = @_;
my($file,$check,$dot_number,$hit,$unlink_files,@filelist);


# 一定確率で実行する場合 ( $random 回に 1回 の確率 )
	if($random && rand($random) < 1){ return; }

# 汚染チェックとリターン
$directory =~ s/\/$//g;
	if($directory eq ""){ return; }
	if($directory =~ /^\//){ return; }
$dot_number =~ ($directory =~ s/\.\.\//$&/g);
	if($dot_number >= 4){ return; }
$unlink_time =~ s/[^0-9\.]//;
	if($unlink_time eq ""){ return; }

# ファイル一覧を取得
opendir(DIR,"$directory") or return();
@filelist = grep(/([a-z])/,readdir(DIR));
close DIR;

# ファイルを展開
foreach $file (@filelist) {
	# ディレクトリをエスケープ
	if(-d $file){ next; }
	# 特定の拡張子のみを削除対象に
	if($file !~ /\.(log|cgi)$/){ next; }
	# ファイルの最終更新日が～日以上前であれば、ファイルを削除
	if (-M "$directory/$file" >= $unlink_time) {
unlink("$directory/$file");
$unlink_files .= qq($file / );
$hit++;
	}
}

# アクセスログを記録
&access_log("OLDREMOVE","$hit ファイルを削除	Dir: $directory		Files: $unlink_files");

# リターン
return($hit,$unlink_files);

}

1;
