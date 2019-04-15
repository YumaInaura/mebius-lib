
use strict;
#use CGI;


#-----------------------------------------------------------
# アップロードの基本設定
#-----------------------------------------------------------
sub init_upload{

# 宣言
my($type,$realmoto) = @_;
my($upload_url,$upload_dir,$realmoto2);

# 汚染チェック
$realmoto =~ s/\W//;
if($realmoto eq ""){ return(); }

$realmoto2 = $realmoto;
$realmoto2 =~ s/^sc//g;

# 設定
$upload_dir = "${main::int_dir}_upload/_${realmoto}_upload/";
$upload_url = "/upload/upload_${realmoto2}/";

	# ローカルでの設定
	if($main::alocal_mode){
		$upload_dir = "C:/Program Files/Apache Software Foundation/Apache2.2/htdocs/upload_${realmoto}/";
		$upload_url = "/upload_${realmoto2}/";
	}

# リターン
return($upload_url,$upload_dir);

}

no strict;

#-------------------------------------------------
#  画像アップロード
#-------------------------------------------------
sub upload {

# 宣言
my($flag,$line,$buffer,$tail,$tail2,$filename,$imagetail_flag);

$cgipm_query = new CGI;

# ファイル定義
my $file = $cgipm_query->param('upfile'); 

# 拡張子判定
($filename,$tail) = split(/\./,$file);
$tail = qq(.$tail);
$tail =~ tr/A-Z/a-z/;

# ファイル名、拡張子がない場合はリターン
if($filename eq "" || $tail eq ""){ return; }

# アップロードを許可するファイル形式
my $gif   = 1;	# GIFファイル
my $jpeg  = 1;	# JPEGファイル
my $png   = 1;	# PNGファイル
my $text  = 1;	# TEXTファイル
my $lha   = 0;	# LHAファイル
my $zip   = 0;	# ZIPファイル
my $pdf   = 1;	# PDFファイル
my $midi  = 1;	# MIDIファイル
my $word  = 0;	# WORDファイル
my $excel = 0;	# EXCELファイル
my $ppt   = 0;	# POWERPOINTファイル
my $ram   = 0;	# RAMファイル
my $rm    = 0;	# RMファイル
my $mpeg  = 0;	# MPEGファイル
my $mp3   = 0;	# MP3ファイル
my $swf   = 0;  # SWFファイル

# アップロードファイル形式を判定（１．ファイル名）
if($tail =~ /\.gif$/i && $gif) { $tail=".gif"; $flag=1; }
if($tail =~ /\.jpe?g$/i && $jpeg) { $tail=".jpg"; $flag=1; }
if($tail =~ /\.png$/i && $png) { $tail=".png"; $flag=1; }
if($tail =~ /\.lzh$/i && $lha) { $tail=".lzh"; $flag=1; }
if($tail =~ /\.txt$/i && $text) { $tail=".txt"; $flag=1; }
if($tail =~ /\.zip$/i && $zip) { $tail=".zip"; $flag=1; }
if($tail =~ /\.pdf$/i && $pdf) { $tail=".pdf"; $flag=1; }
if($tail =~ /\.mid$/i && $midi) { $tail=".mid"; $flag=1; }
if($tail =~ /\.doc$/i && $word) { $tail=".doc"; $flag=1; }
if($tail =~ /\.xls$/i && $excel) { $tail=".xls"; $flag=1; }
if($tail =~ /\.ppt$/i && $ppt) { $tail=".ppt"; $flag=1; }
if($tail =~ /\.ram$/i && $ram) { $tail=".ram"; $flag=1; }
if($tail =~ /\.rm$/i && $rm) { $tail=".rm"; $flag=1; }
if($tail =~ /\.mpe?g$/i && $mpeg) { $tail=".mpg"; $flag=1; }
if($tail =~ /\.mp3$/i && $mp3) { $tail=".mp3"; $flag=1; }
if($tail =~ /\.swf$/i && $swf) { $tail=".swf"; $flag=1; }

# アップロードファイル形式によるエラー （１）
if(!$flag){ $e_com .= qq(▼この形式はアップロードできません。<br>); $emd++; return; }

# 添付ファイル名定義
my $rand = int rand 100;
my $imgfile = "$upload_dir$time-$rand$tail";

# 添付ファイル書き込み
open(OUT,">$imgfile");
binmode(OUT);
while(read($file,$buffer, 1024)){ print OUT $buffer; }
close (OUT);
chmod(0604,$imgfile);

	# アップロードファイル形式の判定、ファイルサイズ判定 ( ２．ImageMagick )
	if(!$alocal_mode){

		require Image::Magick;

		$flag = "";
		my $image = Image::Magick->new;
		$image->Read("$imgfile"); 
		my $filesize = $image->Get("filesize");
		my $file_kbyte = int($filesize / 1024);
		if($filesize > $upload_maxkbyte*1024){ unlink($imgfile); $e_com .= qq(▼ファイルの容量が大きすぎます。 ( ${file_kbyte}KB / ${upload_maxkbyte}KB )<br>); $emd++; return; }
		my $mimetype = $image->Get("mime");
		if($mimetype =~ /image\/gif/i && $gif) { $tail2=".gif"; $flag=1; }
		if($mimetype =~ /image\/p?jpeg/i && $jpeg) { $tail2=".jpg"; $flag=1; }
		if($mimetype =~ /image\/x-png/i && $png) { $tail2=".png"; $flag=1; }
		if($mimetype =~ /image\/png/i && $png) { $tail2=".png"; $flag=1; }
		if($mimetype =~ /text\/plain/i && $text) { $tail2=".txt"; $flag=1; }
		if($mimetype =~ /lha/i && $lha) { $tail2=".lzh"; $flag=1; }
		if($mimetype =~ /zip/i && $zip) { $tail2=".zip"; $flag=1; }
		if($mimetype =~ /pdf/i && $pdf) { $tail2=".pdf"; $flag=1; }
		if($mimetype =~ /audio\/.*mid/i && $midi) { $tail2=".mid"; $flag=1; }
		if($mimetype =~ /msword/i && $word) { $tail2=".doc"; $flag=1; }
		if($mimetype =~ /ms-excel/i && $excel) { $tail2=".xls"; $flag=1; }
		if($mimetype =~ /ms-powerpoint/i && $ppt) { $tail2=".ppt"; $flag=1; }
		if($mimetype =~ /audio\/.*realaudio/i && $ram) { $tail2=".ram"; $flag=1; }
		if($mimetype =~ /application\/.*realmedia/i && $rm) { $tail2=".rm"; $flag=1; }
		if($mimetype =~ /video\/.*mpeg/i && $mpeg) { $tail2=".mpg"; $flag=1; }
		if($mimetype =~ /audio\/.*mpeg/i && $mp3) { $tail2=".mp3"; $flag=1; }
		if($mimetype =~ /shockwave\-flash/i && $swf) { $tail2=".swf"; $flag=1; }
		if($tail ne $tail2){ unlink($imgfile); $e_com .= qq(▼ファイルの拡張子 ( $tail ) と、元のファイルタイプ ( $tail2 ) が違います。拡張子を変えずにアップロードしてください。<br>); $emd++; return; }
		$tail = $tail2;
	}

	# アップロードファイル形式によるエラー （２）
	if(!$flag && !$alocal_mode){
		unlink($imgfile);
		$e_com .= qq(▼この形式はアップロードできません。<br>);
		$emd++;
		return;
	}

# 後処理用のフック
$upload_file = "$time-$rand$tail";

# アップロード記録ファイルを書き込み
open(OUT,">","$upload_dir$time-$rand.cgi");
print OUT qq(1<>$username<>$time<>\n);
close(OUT);
close($file) if ($CGI::OS ne 'UNIX'); # Windowsプラットフォーム用
Mebius::Chmod(undef,"$upload_dir$time-$rand.cgi");

# ファイル形式が画像の場合、フラグを立てる
if($tail eq ".jpg" || $tail eq ".png" || $tail eq ".gif"){ $imagetail_flag = 1; }

	# 縮小画像を作成
	if(!$alocal_mode && $imagetail_flag){ &upload_size("$time-$rand",$tail); }

	# 画像を回転
	if(!$alocal_mode && $imagetail_flag && $in{'turn'}){ &turn_image("$time-$rand",$tail); }

undef $image;


}

#-----------------------------------------------------------
# 画像サイズの処理
#-----------------------------------------------------------
sub upload_size{

require Image::Magick;

# 局所化
my($file,$tail) = @_;
my($scale);

# 画像の最大幅、最大高
my $maxwidth = 300;
my $maxheight = 300;

# ファイル定義
my $imgfile = "${upload_dir}$file$tail";

#-- オブジェクト作成 --#
my $image = Image::Magick->new;

#-- 画像を読込む --#
$image->Read("$imgfile");

# 画像サイズ取得
my($upload_width, $upload_height) = $image->Get('width', 'height');

	# 縮尺を計算（幅）
	if($upload_width > $maxwidth) { $scale = $maxwidth / $upload_width; }

	# 縮尺を計算（高さ）
	if($upload_height > $maxheight) {
		my $scale2 = $maxheight / $upload_height;
			if(!$scale || ($scale2 < $scale) ){ $scale = $scale2; }
	}

#-- 縮小／拡大 --#
$image->Resize(
width  => int($upload_width  * $scale),
height => int($upload_height * $scale),
blur   => 0.8
);

	# 本文に追加する、画像タグ用の定義
	if(!$adjusted_width){ $adjusted_width = $upload_width; }
	if(!$adjusted_height){ $adjusted_height  = $upload_height; }

#-- 画像を保存する(JPEG) --#
our $upload_file_adjusted = "${upload_dir}${file}_s.jpg";
$image->Write($upload_file_adjusted);
chmod(0604,"${upload_dir}${file}_s.jpg");

	# 画像を回転
	if(!$alocal_mode && $in{'turn'}){ &turn_image("${file}_s",".jpg"); }

undef $image;


}

#-----------------------------------------------------------
# 画像を回転
#-----------------------------------------------------------
sub turn_image{

my($filename,$tail) = @_;
my($degrees);

my $file = "${upload_dir}$filename$tail";

my $image = Image::Magick->new;
$image->Read($file);

# 画像を回転させる
if($in{'turn'} eq "right"){ $degrees = 90; }
elsif($in{'turn'} eq "reverse"){ $degrees = 180; }
elsif($in{'turn'} eq "left"){ $degrees = 270; }
else{ return; }

# 傾き
$image->Rotate(degrees=>$degrees);

# 画像を保存
$image->Write("${file}");
chmod(0604,"${file}");

undef $image;

}

#-----------------------------------------------------------
# アップロード用のフォーム
#-----------------------------------------------------------
sub upload_setup{

# タイプ定義
my($type) = @_;
my($turn_checked1,$turn_checked2);
my($my_use_device) = Mebius::my_use_device();
our($k_access,$checked);

# AUの場合
if($k_access eq "AU"){ return; }

	# アップロードファイル名を再定義
	if($upload_file eq "" && $in{'upload_file'}){
		$upload_file = $in{'upload_file'};
	}
	$upload_file =~ s/(\.\.|\/)//g;

	# 画像添付フォーム（携帯版）
	if($type eq "k"){

			if($upload_file){
				$input_upload = qq(<span$main::kfontsize_small>画像 $upload_file<input type="hidden" name="upload_file" value="$upload_file"$xclose><br$xclose>
			</span>);
			}
			else{
if($k_access eq "SOFTBANK"){ $turn_checked2 = $checked; }
else{ $turn_checked1 = $checked; }

$input_upload = qq(
<span$main::kfontsize_small>
画像 <input type="file" name="upfile" size="8"$xclose>
 ※JPG PNG GIF 形式 [ ${upload_maxkbyte}KBまで ]<br$xclose>
画像回転 <input type="radio" name="turn" value=""$turn_checked1$xclose>正
<input type="radio" name="turn" value="right"$turn_checked2$xclose>右
<input type="radio" name="turn" value="reverse"$xclose>逆
<input type="radio" name="turn" value="left"$xclose>左
</span>
<br$xclose>
);
			}
	}

	# 画像添付フォーム（ＰＣ版）
	else{
			if($upload_file){ $input_upload = qq(<input type="hidden" name="upload_file" value="$upload_file">$upload_file); }
			else{ $input_upload = qq(
				<input type="file" name="upfile">
				<span class="guide">※JPG PNG GIF 形式 [ ${upload_maxkbyte}KBまで ] </span>
				　
				<span class="turn">
				画像回転 
				<label><input type="radio" name="turn" value="" checked><span>正</span></label>
				<label><input type="radio" name="turn" value="left"><span>左</span></label>
				<label><input type="radio" name="turn" value="reverse"><span>逆</span></label>
				<label><input type="radio" name="turn" value="right"><span>右</span></label>
				</span>
				);
			}
		my $label_text;

				if(!$my_use_device->{'smart_phone_flag'}){
					$label_text = "画像";
				}
		$input_upload = qq(<tr><td class="no2 valign-top">$label_text</td><td class="no">$input_upload</td></tr>);
	}

# 縮小版ファイル
$s_upload_file = $upload_file;
$s_upload_file =~ s/\.([a-z]+)$/_s\.jpg/;

# フォームタイプ
$formtype =  ' enctype="multipart/form-data"';

}

#-----------------------------------------------------------
# 本文に画像・ＵＲＬを追加
#-----------------------------------------------------------
sub upload_com{

require Image::Magick;

# 宣言
my($comment) = @_;

# 画像ファイル定義
my($imgfile) = "http://${server_domain}${upload_url}$upload_file";
my($s_imgfile) = "http://${server_domain}${upload_url}$s_upload_file";
if($alocal_mode){ $imgfile = $s_imgfile = "${upload_url}$upload_file"; }


	# 縮小後画像のサイズを取得
	if(!$alocal_mode){
		my $image = Image::Magick->new;
		$image->Read("${upload_dir}$s_upload_file");
		($adjusted_width,$adjusted_height) = $image->Get('width', 'height');
		undef $image;
	}

	# 表示方式
	if($upload_file =~ /(\.gif$|\.png$|\.jpg$)/){
		$comment = qq(<a href="$imgfile"><img src="$s_imgfile" alt="添付画像" class="noborder" style="width:${adjusted_width}px;height:${adjusted_height}px;"></a><br><br>$comment);
	}
	else{
		$comment = qq(http://$server_domain/${upload_dir}$upload_file<br><br>$comment);
	}

return ($comment);

}

1;
