#-----------------------------------------------------------
# �����ݒ�
#-----------------------------------------------------------
sub main_msc{

# �^�C�g��
$title = qq(���y�̍Đ� | ������䂤��);
$head_link1 = qq( &gt; <a href="/">���r�E�X�����O</a> | <a href="http://mb2.jp/">��y��</a> );
$head_link2 = qq( &gt; ���y�̍Đ� );

# �X�N���v�g��`
$script = "./";
if($alocal_mode){ $script = "main.cgi"; }

# ���y�p�f�B���N�g��
our $music_url_redirect = "http://aurasoul.mb2.jp/msc2/";
$msc_url = "http://aurasoul.mb2.jp/msc2/";
$play_url = "http://aurasoul.mb2.jp/_main/?mode=msc-play&amp;file=";
$msc_dir = "../msc2/";
if($alocal_mode){ $msc_dir = "./msc/"; }

# �T�[�o�[�w��
if($server_domain ne "aurasoul.mb2.jp" && $server_domain ne "localhost"){ &error("�h���C�����Ⴂ�܂��B"); }

# ���[�h�U�蕪��
if($submode2 eq "play"){ Mebius::Music::Play($in{'file'}); }
elsif($submode2 eq "comment"){ &mscomment(); }
elsif($submode2 eq "list"){ &music_list(); }
elsif($submode2 eq "slist"){ &music_slist(); }
elsif($submode2 eq "editsource"){ &editsource(); }
else{ &error("���[�h���w�肵�Ă��������B"); }

exit;

}


#-----------------------------------------------------------
# �Đ����X�g��\��
#-----------------------------------------------------------
sub music_list{

# �Ǐ���
my(@line);

# �y�[�W�^�C�v
my $page = $submode4;
$page =~ s/\D//g;
if($page eq ""){ &error("�y�[�W�����w�肵�Ă��������B"); }

# CSS��`
$css_text .= qq(
li{line-height:1.5em;}
ul{margin:1em 0em 0em 0em;}
h1{margin-top:0em;}
textarea.source{width:100%;height:500px;}
table,th,tr,td{border-style:none;}
table{margin-top:1em;}
th{text-align:left;padding:0.2em 1.0em 0.4em 0em;}
td{padding:0.2em 1.0em 0.4em 0em;}
th.mark,td.mark,span.mark{color:#f83;}
th.mark{padding-right:1.0em;}
td.mark{padding-right:1.0em;}
th.sub{}
th.count{text-align:right;padding-right:1.5em;}
th.count{}
td.count{text-align:right;padding-right:1.5em;}
th.word{}
th.k{}
th.url{}
td.url{padding-top:0em;padding-bottom:0em;}
div.tablinks{margin-top:1em;padding:0.4em 1em;background-color:#dee;}
input.url{font-size:70%;color:#080;border:none 0px #fff;width:27em;height:1.7em;}
.zero_mark{color:#000;}
.crap{display:inline;}
form.msform{background-color:#ff9;padding:0.4em 1em;margin:1em 0em;}
input.mscomment{width:30%;}
);


# �Đ����X�g�t�@�C�����J��
open(COUNT_IN,"${msc_dir}play.cgi");
while(<COUNT_IN>){ push(@line,$_); }
close(COUNT_IN);

# ���בւ�
if($submode3 eq "normal"){ $sub_title = qq($title); }
elsif($submode3 eq "count"){ @line = sort { (split(/<>/,$b))[3] <=> (split(/<>/,$a))[3] } @line; $sub_title = qq(�Đ��񐔏� - $title); }
elsif($submode3 eq "title"){ @line = sort { (split(/<>/,$a))[1] cmp (split(/<>/,$b))[1] } @line; $sub_title = qq(�^�C�g���� - $title); }
else{ &error("�\���^�C�v���w�肵�Ă��������B"); }

	# �Đ����X�g�t�@�C�����J��
	foreach(@line){
		my($key,$sub,$mscfile,$count,$support,$word_url,$xip_enc2) = split(/<>/,$_);
		if($key eq "0" && $myadmin_flag < 5){ next; } 
		$line .= qq(<tr>);
		my($mark);
		if($key eq "0"){ $line .= qq(<td class="zero_mark">��</td>); }
		elsif($key eq "5"){ $line .= qq(<td class="mark">��</td>); }
		else { $line .= qq(<td class="mark">��</td>); }
		if($sub eq ""){ $sub = $mscfile; }
		if($cookie || $k_access){ $line .= qq(<td>$mark<a href="$script?mode=msc-play&amp;file=$mscfile">$sub</a></td>); }
		else{ $line .= qq(<td><a href="${msc_url}$mscfile.mp3">$sub</a></td>); }
		$line .= qq(<td class="count">$count��</td>);
		if($cookie || $k_access){ $line .= qq(<td><a href="$script?mode=msc-play&amp;file=$mscfile&amp;k=1">�g�є�</a></td>); }
		else{ $line .= qq(<td><a href="http://mp3.3gp.fm/q/Link.aspx?u=http%3a%2f%2faurasoul.mb2.jp%2fmsc%2f$mscfile.mp3">�g�є�</a></td>); }
		if($word_url){ $line .= qq(<td><a href="$word_url">�̎�</a></td>); } else { $line .= qq(<td></td>); }
		$line .= qq(<td class="url"><input type="text" class="url" value="${play_url}$mscfile" onclick="select()"></td>);
		$line .= qq(</tr>\n);
	}

# �}�X�^�[�̏ꍇ�A�\�[�X���擾
if($myadmin_flag >= 5){ &get_source; }

# �؂�ւ������N���擾
&get_tablinks;

# �ꌾ���b�Z�[�W�t�H�[�����擾
#my($msform_line) = &get_msform;



# �Đ��\���`
my($table);
$table = qq(
<table summary="�Đ����X�g">
<tr><th class="mark"></th><th class="sub"><strong class="red">�Ȗ� �� �Đ�����</strong></th><th class="count">�Đ�</th><th class="k">�g�є�</th><th class="word">�̎�</th><th>�����̂t�q�k�i�\\��t���p�j</th></tr>
$line
</table>
);


# HTML
my $print = qq(
<h1>���y�̍Đ�</h1>
<h2>�Đ����X�g</h2>
���y�̍Đ����X�g�ł��B�����ɖ������̂�<a href="http://aurasoul.mb2.jp/_ams/">������̉�</a>��<a href="http://aurasoul.mb2.jp/_asx/">�˗���i�W</a>����Ȃ�T���čĐ�����ƁA���X�g�ɒǉ�����܂��B<span class="mark">��</span>�͂������ߋȂł��B
$msform_line

$tablinks
$table
$source_line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;


}


#-----------------------------------------------------------
# �ꌾ���b�Z�[�W�t�H�[��
#-----------------------------------------------------------
sub get_msform{

if(!$cookie && !$k_access){ return; }

my($line);

$line .= qq(
<form action="$script" method="post" class="msform" $sikibetu>
<div>
<input type="hidden" name="mode" value="msc-comment">
<input type="text" name="comment" value="" class="mscomment">
<input type="submit" value="�ꌾ���b�Z�[�W�𑗂�">
</div>
</form>
);

return($line);

}

#-----------------------------------------------------------
# �ꌾ���b�Z�[�W�𑗂�
#-----------------------------------------------------------
sub mscomment{

# �h�c�t�^
&id;

# �A�N�Z�X����
&axscheck("fast");

# �e��G���[
if(!$cookie && !$k_access){ &error("���̊��ł͑��M�ł��܂���B"); }
if(!$postflag){ &error("GET���M�͏o���܂���B"); }
if(length($in{'comment'}) > 2000*2){ &error("�R�����g��2000�����ȓ��ŏ����Ă��������B"); }
if(length($in{'comment'}) < 2*2){ &error("�R�����g��2�����ȏ�ŏ����Ă��������B"); }
if($in{'comment'} =~/(href|url=)/){ &error("�^�O�͑��M�ł��܂���B"); }

# ���M���e�̒�`
my $body = qq(
$in{'comment'}

������������������������������������������������������������
�M���F $chandle
�h�c�F $encid
�A�J�E���g�F $auth_url$pmfile/
�ڑ����F $xip - $addr
������������������������������������������������������������

);

# �M��
my $name = $chandle;
if($name eq ""){ $name = "������"; }

# ���[�����M
Mebius::send_email("To-master",undef,"���y�̍Đ� - $name���񂪃��b�Z�[�W�𑗐M���܂����B",$body);

# �W�����v��
$jump_sec = 1;
$jump_url = "msc-list-normal-1.html";
if($alocal_mode){ $jump_url = "$script?mode=msc-list-normal-1"; }


# HTML
my $print = qq(
���M���܂����B<a href="$jump_url">�߂�</a>
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-----------------------------------------------------------
# �ȈՍĐ����X�g��\��
#-----------------------------------------------------------
sub music_slist{

# �Ǐ���
my(@line,$hit);

my $rand = rand(2);

# �Đ����X�g�t�@�C�����J��
open(COUNT_IN,"${msc_dir}play.cgi");

# �Đ����X�g�t�@�C�����J��
while(<COUNT_IN>){
if($hit >= 3){ last; }
my($key,$sub,$mscfile,$count,$support,$word_url,$xip_enc2) = split(/<>/);
if($key eq "0"){ next; }

if($rand < 1 && $key ne "5"){ next; }
if($rand >= 1 && ($count < 10 || $key eq "5")){ next; }
if(rand(2) < 1){ next; }

if($sub eq ""){ $sub = $mscfile; }
$sub =~ s/ (-|�i|\()(.+)//g;

$line .= qq(<li>);
if($k_access){ $line .= qq(<a href="$script?mode=msc-play&amp;file=$mscfile&amp;k=1">$sub</a>); }
elsif($cookie && !$bot_access){ $line .= qq(<a href="$script?mode=msc-play&amp;file=$mscfile">$sub</a>); }
else{ $line .= qq(<a href="${msc_url}$mscfile.mp3">$sub</a>); }

if($word_url){ $line .= qq( ( <a href="$word_url">�̎�</a> ) ); }
$hit++;
}
close(COUNT_IN);

# �w�b�_
print "Content-type:text/html\n\n";

print qq(
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd"> 
<html lang="ja"> 
<head>
<base target="_top">
<meta http-equiv="content-type" content="text/html; charset=shift_jis"> 
<title>���y�̍Đ� - �ȈՃ��X�g</title> 
<meta name="robots" content="noarchive"> 
<meta http-equiv="content-style-type" content="text/css"> 
<style type="text/css"> 
<!--
body{background-color:#ffd;}
ul{margin:0em;padding-left:1em;}
li{line-height:1.5em;margin:0em;}
-->
</style> 
</head>
);

# HTML
print qq(<body><div><ul>$line</ul></div>);

# �t�b�^
print qq(</body></html>);

exit;


}



#-----------------------------------------------------------
# �؂�ւ������N���`
#-----------------------------------------------------------
sub get_tablinks{

# �Ǐ���
my($i);

# �����N���`
my @tablinks = (
'normal=�V�K�Đ���',
'count=�Đ��񐔏�',
'title=�^�C�g����'
);

# �����N��W�J
foreach(@tablinks){
my($type,$name) = split(/=/);
$i++;
if($i >= 2){ $tablinks .= qq( - ); }
if($type eq $submode3){ $tablinks .= qq($name); }
else{ $tablinks .= qq(<a href="${script}msc-list-$type-1.html">$name</a>); }
}

$tablinks .= qq(�@�b�@) . qq(<a href="http://aurasoul.mb2.jp/_shop/v-song.html">�쎌��ȃT�[�r�X</a>);


# ���`
#$tablinks = qq(<h2>�Đ��`��</h2>$tablinks);
$tablinks = qq(<div class="tablinks">$tablinks</div>);

}

#-----------------------------------------------------------
# �\�[�X�ύX�t�H�[��
#-----------------------------------------------------------
sub get_source{

open(COUNT_IN,"${msc_dir}play.cgi");
while(<COUNT_IN>){
s/>/&gt;/g;
s/</&lt;/g;
s/"/&quot;/g;
$source_line .= qq($_);

}
close(COUNT_IN);

$source_line = qq(
<h2>�\\�[\�X�ύX</h2>
 [ �L�[&lt;&gt;�Ȗ�&lt;&gt;���y�t�@�C����&lt;&gt;�Đ���&lt;&gt;�]����&lt;&gt;�w�h�o ] <br><br>

<form action="$script" method="post">
<div>
<textarea name="source" rows="50" cols="50" class="source">$source_line</textarea>
<input type="hidden" name="mode" value="msc-editsource">
<input type="submit" value="�\\�[\�X\��ύX����">
</div>
</form>

);

}

#-----------------------------------------------------------
# �\�[�X�ύX���������s
#-----------------------------------------------------------
sub editsource{

# �Ǘ��҂łȂ��ꍇ
if($myadmin_flag < 5){ &error("�t�@�C�������݂��܂���B"); }

# ���̓\�[�X��ϊ�
$in{'source'} =~ s/<br>/\n/g;
$in{'source'} =~ s/&gt;/>/g;
$in{'source'} =~ s/&lt;/</g;
$in{'source'} =~ s/&quot;/"/g;

# �댯�ȃ^�O��r��
Mebius::DangerTag("Error-view",$in{'source'});

# ���b�N�J�n
&lock("mscplay") if $lockkey;

# �v���C���X�g�t�@�C�����X�V
Mebius::Fileout(undef,"${msc_dir}play.cgi",$in{'source'});

# ���b�N����
&unlock("mscplay") if $lockkey;

# ���_�C���N�g
print "location:$script?mode=msc-list-normal-1\n\n";

exit;

}


use strict;
package Mebius::Music;

#-----------------------------------------------------------
# �y�Ȃ��Đ��A�J�E���g����
#-----------------------------------------------------------
sub Play{

# �錾
my($file) = @_;
my($return);

	# �t�@�C����`
	if($file =~ /\/|\.\./ || $file =~ /[^\w\.\-]/){ main::error("�t�@�C���w�肪�ςł��B"); }
	if($file eq ""){ main::error("�t�@�C�����w�肵�Ă��������B"); }
my($file_encoded) = Mebius::Encode(undef,$file);

	# �����t�@�C���̗L�����`�F�b�N
	if($file !~ /\.(\w+)$/){ $file = "$file.mp3"; }
	if(!-f "${main::msc_dir}$file"){ main::error("���݂��Ȃ��t�@�C���ł��B"); }

	# �J�E���g�J�n
	if(($main::agent || $main::cookie || $main::k_access) && !$main::bot_access){
		&Count();
		&PlayIndex(undef,$file);
	}

	# ���_�C���N�g
	if($main::in{'k'} || (!$main::bot_access && $main::device_type eq "mobile")){
		my($url_encoded) = Mebius::Encode(undef,"$main::music_url_redirect$file");
		#Mebius::Redirect(undef,"http://mp3.3gp.fm/q/Link.aspx?u=$url_encoded");
		Mebius::Redirect("","$main::music_url_redirect$file",301);
	}
	else{
		Mebius::Redirect("","$main::music_url_redirect$file",301);
	}

exit;
}

#-----------------------------------------------------------
# �Đ��񐔃t�@�C�� ( �� )
#-----------------------------------------------------------
sub Count{


}


no strict;

#-----------------------------------------------------------
# �Đ��񐔂��J�E���g ( �C���f�b�N�X )
#-----------------------------------------------------------
sub PlayIndex{

# �錾
my($type,$file) = @_;
my($line,$plus_line,$flag,$nomake_flag,$newkey,$count_handler,$redun_count_flag);

# �t�@�C����`
if($file eq ""){ return; }
my($file_encoded) = Mebius::Encode(undef,$file);
my $count_file = "${main::int_dir}_music/play/${file_encoded}.dat";
my $index_file = "${main::int_dir}_music/play.log";

# ���P�̃t�@�C�����J��
open($count_handler,"<$count_file");

# �t�@�C�����b�N
flock($count_handler,1);

# �g�b�v�f�[�^�𕪉�
chomp(my $top1_count = <$count_handler>);
my($tkey,$tcount,$tsubject) = split(/<>/,$top1_count);

# �V�����L�[���`
if($file =~ /^(pre|mix|back)/){ $tkey = 0; } else { $tkey = 1; }

	# �Ȗ���⊮����
	my $num = ($referer =~ s/^http:\/\/aurasoul\.mb2\.jp\/_(ams|asx|asd|amb)\/([0-9]+)\.html$/$&/g);
	if($word_url eq "" && $num){ $word_url = $referer; }
	if($sub eq "" && $num){ $sub = &get_sub($1,$2); }
	if($file =~ /([0-9]+)\.mp3$/){ $sub = "$sub - take$1"; }
	if($main::myadmin_flag < 5){ $tcount++; }

	# �t�@�C����W�J
	while(<$count_handler>){

		# �s�𕪉�
		chomp;
		my($lasttime2,$addr2,$agent2) = split(/<>/);

		# ��莞�Ԃ��o�߂��Ă���ꍇ
		if($main::time > $lasttime2 * 24*60*60){ next; }

		# �d���J�E���g�̏ꍇ
		if($agent2 && $agent2 eq $main::agent){ $redun_count_flag = 1; }
		if($addr2 && $addr2 eq $main::addr && $main::k_access){ $redun_count_flag = 1; }

		# �X�V�p
		push(@renewline_count,"$lasttime2<>$addr2<>$agent2<>\n");

	}

close($count_handler);

# �J�E���g�����Ƀ��^�[������ꍇ
if($redun_count_flag && $main::myadmin_flag < 5){ return(); }

# �v���C���X�g�t�@�C�����J��
open($index_handler,"<$index_file");

	# �t�@�C�����b�N
	flock($index_handler,1);

	# �t�@�C����W�J
	while(<$index_handler>){
		chomp;
		my($key,$sub,$mscfile,$count,$support,$word_url) = split(/<>/);
			if($mscfile eq $file){
				$flag = 1;

				if($myadmin_flag < 5){ $count++; }
				$plus_line = qq($key<>$sub<>$mscfile<>$count<>$support<>$word_url<><>\n);
			}
			else{ $line .= qq($key<>$sub<>$mscfile<>$count<>$support<>$word_url<>$addr2<>\n); }
	}
close($index_handler);

	# �����Œ������ꍇ�ȂǁA���^�[��
	if($flag && $myadmin_flag >= 5){ return; }
	if($file =~ /^back-/){ return; }

# �V�K�s�̍쐬
$line = $plus_line . $line;
$line = qq($tkey<>$tsubject<>$file<>$count<><>$word_url<><>\n) . $line;

# �v���C���X�g�t�@�C�����X�V
Mebius::Fileout(undef,$index_file,$line);

# �Đ��񐔂̃J�E���g�t�@�C�����X�V
unshift(@renewline_count,"$main:addr<>$main::agent<>\n");
unshift(@renewline_count,"$tkey<>$tcount<>$tsubject<>\n");
Mebius::Fileout(undef,$count_file,@renewline_count);

}

package main;

#-----------------------------------------------------------
# ���L���̑薼�擾
#-----------------------------------------------------------
sub get_sub{

# �t�@�C����`
my($moto,$no) = @_;
$moto =~ s/\W//g;
$no =~ s/\D//g;
	if($moto eq ""){ return; }
	if($no eq ""){ return; }

open(DATA_IN,"${int_dir}${moto}_log/$no.cgi");
my $top = <DATA_IN>;
my($no,$sub) = split(/<>/,$top);
close(DATA_IN);

return ($sub);
}

# �錾
use strict;
package Mebius::Music;





1;
