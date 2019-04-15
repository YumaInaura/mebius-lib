
use strict;
#use CGI;


#-----------------------------------------------------------
# �A�b�v���[�h�̊�{�ݒ�
#-----------------------------------------------------------
sub init_upload{

# �錾
my($type,$realmoto) = @_;
my($upload_url,$upload_dir,$realmoto2);

# �����`�F�b�N
$realmoto =~ s/\W//;
if($realmoto eq ""){ return(); }

$realmoto2 = $realmoto;
$realmoto2 =~ s/^sc//g;

# �ݒ�
$upload_dir = "${main::int_dir}_upload/_${realmoto}_upload/";
$upload_url = "/upload/upload_${realmoto2}/";

	# ���[�J���ł̐ݒ�
	if($main::alocal_mode){
		$upload_dir = "C:/Program Files/Apache Software Foundation/Apache2.2/htdocs/upload_${realmoto}/";
		$upload_url = "/upload_${realmoto2}/";
	}

# ���^�[��
return($upload_url,$upload_dir);

}

no strict;

#-------------------------------------------------
#  �摜�A�b�v���[�h
#-------------------------------------------------
sub upload {

# �錾
my($flag,$line,$buffer,$tail,$tail2,$filename,$imagetail_flag);

$cgipm_query = new CGI;

# �t�@�C����`
my $file = $cgipm_query->param('upfile'); 

# �g���q����
($filename,$tail) = split(/\./,$file);
$tail = qq(.$tail);
$tail =~ tr/A-Z/a-z/;

# �t�@�C�����A�g���q���Ȃ��ꍇ�̓��^�[��
if($filename eq "" || $tail eq ""){ return; }

# �A�b�v���[�h��������t�@�C���`��
my $gif   = 1;	# GIF�t�@�C��
my $jpeg  = 1;	# JPEG�t�@�C��
my $png   = 1;	# PNG�t�@�C��
my $text  = 1;	# TEXT�t�@�C��
my $lha   = 0;	# LHA�t�@�C��
my $zip   = 0;	# ZIP�t�@�C��
my $pdf   = 1;	# PDF�t�@�C��
my $midi  = 1;	# MIDI�t�@�C��
my $word  = 0;	# WORD�t�@�C��
my $excel = 0;	# EXCEL�t�@�C��
my $ppt   = 0;	# POWERPOINT�t�@�C��
my $ram   = 0;	# RAM�t�@�C��
my $rm    = 0;	# RM�t�@�C��
my $mpeg  = 0;	# MPEG�t�@�C��
my $mp3   = 0;	# MP3�t�@�C��
my $swf   = 0;  # SWF�t�@�C��

# �A�b�v���[�h�t�@�C���`���𔻒�i�P�D�t�@�C�����j
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

# �A�b�v���[�h�t�@�C���`���ɂ��G���[ �i�P�j
if(!$flag){ $e_com .= qq(�����̌`���̓A�b�v���[�h�ł��܂���B<br>); $emd++; return; }

# �Y�t�t�@�C������`
my $rand = int rand 100;
my $imgfile = "$upload_dir$time-$rand$tail";

# �Y�t�t�@�C����������
open(OUT,">$imgfile");
binmode(OUT);
while(read($file,$buffer, 1024)){ print OUT $buffer; }
close (OUT);
chmod(0604,$imgfile);

	# �A�b�v���[�h�t�@�C���`���̔���A�t�@�C���T�C�Y���� ( �Q�DImageMagick )
	if(!$alocal_mode){

		require Image::Magick;

		$flag = "";
		my $image = Image::Magick->new;
		$image->Read("$imgfile"); 
		my $filesize = $image->Get("filesize");
		my $file_kbyte = int($filesize / 1024);
		if($filesize > $upload_maxkbyte*1024){ unlink($imgfile); $e_com .= qq(���t�@�C���̗e�ʂ��傫�����܂��B ( ${file_kbyte}KB / ${upload_maxkbyte}KB )<br>); $emd++; return; }
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
		if($tail ne $tail2){ unlink($imgfile); $e_com .= qq(���t�@�C���̊g���q ( $tail ) �ƁA���̃t�@�C���^�C�v ( $tail2 ) ���Ⴂ�܂��B�g���q��ς����ɃA�b�v���[�h���Ă��������B<br>); $emd++; return; }
		$tail = $tail2;
	}

	# �A�b�v���[�h�t�@�C���`���ɂ��G���[ �i�Q�j
	if(!$flag && !$alocal_mode){
		unlink($imgfile);
		$e_com .= qq(�����̌`���̓A�b�v���[�h�ł��܂���B<br>);
		$emd++;
		return;
	}

# �㏈���p�̃t�b�N
$upload_file = "$time-$rand$tail";

# �A�b�v���[�h�L�^�t�@�C������������
open(OUT,">","$upload_dir$time-$rand.cgi");
print OUT qq(1<>$username<>$time<>\n);
close(OUT);
close($file) if ($CGI::OS ne 'UNIX'); # Windows�v���b�g�t�H�[���p
Mebius::Chmod(undef,"$upload_dir$time-$rand.cgi");

# �t�@�C���`�����摜�̏ꍇ�A�t���O�𗧂Ă�
if($tail eq ".jpg" || $tail eq ".png" || $tail eq ".gif"){ $imagetail_flag = 1; }

	# �k���摜���쐬
	if(!$alocal_mode && $imagetail_flag){ &upload_size("$time-$rand",$tail); }

	# �摜����]
	if(!$alocal_mode && $imagetail_flag && $in{'turn'}){ &turn_image("$time-$rand",$tail); }

undef $image;


}

#-----------------------------------------------------------
# �摜�T�C�Y�̏���
#-----------------------------------------------------------
sub upload_size{

require Image::Magick;

# �Ǐ���
my($file,$tail) = @_;
my($scale);

# �摜�̍ő啝�A�ő卂
my $maxwidth = 300;
my $maxheight = 300;

# �t�@�C����`
my $imgfile = "${upload_dir}$file$tail";

#-- �I�u�W�F�N�g�쐬 --#
my $image = Image::Magick->new;

#-- �摜��Ǎ��� --#
$image->Read("$imgfile");

# �摜�T�C�Y�擾
my($upload_width, $upload_height) = $image->Get('width', 'height');

	# �k�ڂ��v�Z�i���j
	if($upload_width > $maxwidth) { $scale = $maxwidth / $upload_width; }

	# �k�ڂ��v�Z�i�����j
	if($upload_height > $maxheight) {
		my $scale2 = $maxheight / $upload_height;
			if(!$scale || ($scale2 < $scale) ){ $scale = $scale2; }
	}

#-- �k���^�g�� --#
$image->Resize(
width  => int($upload_width  * $scale),
height => int($upload_height * $scale),
blur   => 0.8
);

	# �{���ɒǉ�����A�摜�^�O�p�̒�`
	if(!$adjusted_width){ $adjusted_width = $upload_width; }
	if(!$adjusted_height){ $adjusted_height  = $upload_height; }

#-- �摜��ۑ�����(JPEG) --#
our $upload_file_adjusted = "${upload_dir}${file}_s.jpg";
$image->Write($upload_file_adjusted);
chmod(0604,"${upload_dir}${file}_s.jpg");

	# �摜����]
	if(!$alocal_mode && $in{'turn'}){ &turn_image("${file}_s",".jpg"); }

undef $image;


}

#-----------------------------------------------------------
# �摜����]
#-----------------------------------------------------------
sub turn_image{

my($filename,$tail) = @_;
my($degrees);

my $file = "${upload_dir}$filename$tail";

my $image = Image::Magick->new;
$image->Read($file);

# �摜����]������
if($in{'turn'} eq "right"){ $degrees = 90; }
elsif($in{'turn'} eq "reverse"){ $degrees = 180; }
elsif($in{'turn'} eq "left"){ $degrees = 270; }
else{ return; }

# �X��
$image->Rotate(degrees=>$degrees);

# �摜��ۑ�
$image->Write("${file}");
chmod(0604,"${file}");

undef $image;

}

#-----------------------------------------------------------
# �A�b�v���[�h�p�̃t�H�[��
#-----------------------------------------------------------
sub upload_setup{

# �^�C�v��`
my($type) = @_;
my($turn_checked1,$turn_checked2);
my($my_use_device) = Mebius::my_use_device();
our($k_access,$checked);

# AU�̏ꍇ
if($k_access eq "AU"){ return; }

	# �A�b�v���[�h�t�@�C�������Ē�`
	if($upload_file eq "" && $in{'upload_file'}){
		$upload_file = $in{'upload_file'};
	}
	$upload_file =~ s/(\.\.|\/)//g;

	# �摜�Y�t�t�H�[���i�g�єŁj
	if($type eq "k"){

			if($upload_file){
				$input_upload = qq(<span$main::kfontsize_small>�摜 $upload_file<input type="hidden" name="upload_file" value="$upload_file"$xclose><br$xclose>
			</span>);
			}
			else{
if($k_access eq "SOFTBANK"){ $turn_checked2 = $checked; }
else{ $turn_checked1 = $checked; }

$input_upload = qq(
<span$main::kfontsize_small>
�摜 <input type="file" name="upfile" size="8"$xclose>
 ��JPG PNG GIF �`�� [ ${upload_maxkbyte}KB�܂� ]<br$xclose>
�摜��] <input type="radio" name="turn" value=""$turn_checked1$xclose>��
<input type="radio" name="turn" value="right"$turn_checked2$xclose>�E
<input type="radio" name="turn" value="reverse"$xclose>�t
<input type="radio" name="turn" value="left"$xclose>��
</span>
<br$xclose>
);
			}
	}

	# �摜�Y�t�t�H�[���i�o�b�Łj
	else{
			if($upload_file){ $input_upload = qq(<input type="hidden" name="upload_file" value="$upload_file">$upload_file); }
			else{ $input_upload = qq(
				<input type="file" name="upfile">
				<span class="guide">��JPG PNG GIF �`�� [ ${upload_maxkbyte}KB�܂� ] </span>
				�@
				<span class="turn">
				�摜��] 
				<label><input type="radio" name="turn" value="" checked><span>��</span></label>
				<label><input type="radio" name="turn" value="left"><span>��</span></label>
				<label><input type="radio" name="turn" value="reverse"><span>�t</span></label>
				<label><input type="radio" name="turn" value="right"><span>�E</span></label>
				</span>
				);
			}
		my $label_text;

				if(!$my_use_device->{'smart_phone_flag'}){
					$label_text = "�摜";
				}
		$input_upload = qq(<tr><td class="no2 valign-top">$label_text</td><td class="no">$input_upload</td></tr>);
	}

# �k���Ńt�@�C��
$s_upload_file = $upload_file;
$s_upload_file =~ s/\.([a-z]+)$/_s\.jpg/;

# �t�H�[���^�C�v
$formtype =  ' enctype="multipart/form-data"';

}

#-----------------------------------------------------------
# �{���ɉ摜�E�t�q�k��ǉ�
#-----------------------------------------------------------
sub upload_com{

require Image::Magick;

# �錾
my($comment) = @_;

# �摜�t�@�C����`
my($imgfile) = "http://${server_domain}${upload_url}$upload_file";
my($s_imgfile) = "http://${server_domain}${upload_url}$s_upload_file";
if($alocal_mode){ $imgfile = $s_imgfile = "${upload_url}$upload_file"; }


	# �k����摜�̃T�C�Y���擾
	if(!$alocal_mode){
		my $image = Image::Magick->new;
		$image->Read("${upload_dir}$s_upload_file");
		($adjusted_width,$adjusted_height) = $image->Get('width', 'height');
		undef $image;
	}

	# �\������
	if($upload_file =~ /(\.gif$|\.png$|\.jpg$)/){
		$comment = qq(<a href="$imgfile"><img src="$s_imgfile" alt="�Y�t�摜" class="noborder" style="width:${adjusted_width}px;height:${adjusted_height}px;"></a><br><br>$comment);
	}
	else{
		$comment = qq(http://$server_domain/${upload_dir}$upload_file<br><br>$comment);
	}

return ($comment);

}

1;
