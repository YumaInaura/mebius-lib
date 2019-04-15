
use Mebius::Tag;
package main;

#-----------------------------------------------------------
# SNS�^�O���쐬
#-----------------------------------------------------------
sub auth_maketag{

# �Ǐ���
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$line2,$line2_plus,$line3,$line4,$i,$tag,$comment,$i_word,$i_newtag,$double_flag,$finished_text);
my($mytag_handler,$keyword_handler);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# �A�N�Z�X����
&axscheck("ACCOUNT");

# �t�@�C���I�[�v��
&open($file);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �L�[���[�h���`
$tag = $in{'tag'};
($tag) = Mebius::Tag::FixTag(undef,$tag);

	# ���`
	if(!$in{'plus'}){
		$tag =~ s/(((��|�I|�B|��)+)$)//g;
	}

# �L�[���[�h�̃G���R�[�h
($enc_tag) = Mebius::Encode(undef,$tag);
#$enc_tag =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
#$enc_tag =~ tr/ /+/;

# �R�����g��`
$comment = $in{'comment'};
$comment =~ s/<br>//g;

# �e��G���[
if(!$postflag){ &error("GET���M�͏o���܂���B"); }
if(!$myprof_flag && !$myadmin_flag){ &error("�������o�[�̃^�O�͓o�^�ł��܂���B"); }
if(length($in{'tag'}) > 20*2){ &error("�L�[���[�h�͑S�p20�����܂łł�"); }
if(length($in{'comment'}) > $max_comment*2){ &error("�R�����g�͑S�p$max_comment�����܂łł�"); }
if($tag =~ /(http|\.jp|\.com|\.net)/){ &error("�^�O�ɂt�q�k�͎g���܂���B"); }

# �e��G���[�`�F�b�N
require "${int_dir}regist_allcheck.pl";
&url_check("",$comment);
&base_change($in{'comment'});
&error_view;

# ���t�@�C�����`�F�b�N
open(CLOSE_IN,"<","${auth_log_directory}_closetag/${enc_tag}_close.cgi");
$top_close = <CLOSE_IN>;
my($close_key) = split(/<>/,$top_close);
if($close_key eq "0" || $close_key eq "2"){ &error("���̃^�O�͋֎~����Ă��܂��B"); }
close(CLOSE_IN);

# �L�[���[�h���R�����g�e��G���[
if (($tag =~ /^(\x81\x40|\s)+$/)||($tag eq "")) { &error("�^�O����͂��Ă��������B"); }
@denyword = (
'����','����',
'����','�E���R','�܂�','�}���R','�`���R','����',
'�Z�b�N�X'
);
foreach(@denyword){
if(index($tag,$_) >= 0){ &error("���̃^�O�͓o�^�ł��܂���B"); }
if(index($comment,$_) >= 0){ &error("���̃R�����g�͓o�^�ł��܂���B"); }
}

	# �L�[���[�h�G���[�Q
	if(!$in{'plus'}){
		my($flag,$flag2);
		if($tag =~ /(���܂�|�W�܂�|����$|����$)/){ &error("�l���W�߂�ɂ͌f���������p���������B"); }
		if($tag =~ /(�o�^��|([^a-zA-Z0-9�@])(or|vs|Vs|VS)([^a-zA-Z0-9�@]))/){ $flag2 = 1; }
		if($tag =~ /(��|��|��|��|��|��|��|��|��|��|��|��|��|��|��|��)(�l|�Ђ�|�z)/){ $flag2 = 1; }
		if($flag2){
		&error("�^�O�ɂ́u�P��v��u�����I�ȃL�[���[�h�v���g���Ă��������B�܂��^�O���g���Ắu�f�����p�v��u�l�W�߁v�͂��������������B�@��F �~�z�C�Ȑl�A�W�܂�@���z�C�@"); 
		}

		if($tag =~ /(��|��)(�ꌾ)/){ $flag = 1; }
		if($tag =~ /(�H$|����$|���낤|����$|����$|����$|�ǂꂪ|������|��������|�D����|������|�W��|�W��|���l|\Q���[\E|�����|�ň��|�I�X�X��|��������)/){ $flag = 1; }
		if($tag =~ /(^����|���悤|�݂悤|�߂悤|��̂�|�̂�$|����Ƃ�|�ǂ���|����|�Z�Z)/){ $flag = 1; }
		if(($tag =~ s/�h/$&/g) >= 2){ $flag = 1; }

		#if($tag =~ /����$/){ &error("�^�O�ł̔��Ί����͏o���܂���B"); }

		if($flag){ &error("�^�O���g���Ắu�A���P�[�g�v�u�g���C�A���v�͂��������������B���Ȃ����g�Ɋ֌W����L�[���[�h��o�^���Ă��������B"); }
		if($tag =~ /(����)/){ &error("���������Ȃǂ������Ȃ��ꍇ�́A�f���������p���������B"); }
		if($tag =~ /\Q�^�O\E/){ &error("�^�O�ɂ��Ẵ^�O�͍��܂���B"); }
	}

# ���b�N�J�n
&lock("auth$file") if($lockkey);

# �ǉ�����s
$line .= qq(1<>$tag<>\n);

# �}�C�^�O�t�@�C�����J��
my $openfile1 = "${account_directory}${file}_tag.cgi";
open($mytag_handler,"<","$openfile1");
	while(<$mytag_handler>){
		my($key2,$tag2) = split(/<>/,$_);
		if($tag2 eq $tag && $key2 eq "1"){
		if($in{'edit'}){ next; }
		else{ $double_flag++; next; }
		}
		if($key2 eq "1"){ $i++; } else { next; }
		if($i >= $maxtag){ &error("�^�O��$maxtag�܂ł��B�V�����o�^����ɂ́A������^�O�����炵�Ă��������B"); }
		$line .= $_;
	}
close($mytag_handler);

# �}�C�^�O�t�@�C������������
Mebius::Fileout("",$openfile1,$line);


# ���b�N����
&unlock("auth$file") if($lockkey);

# ���b�N�J�n
&lock("tag$enc_tag") if($lockkey);

# �L�[���[�h�t�@�C�����J��
my($new_flag,$up_edit_flag) = (1,0);

my $openfile2 = "${auth_log_directory}_tag/$enc_tag.cgi";
open($keyword_handler,"<","$openfile2");
	while(<$keyword_handler>){
		chomp;
		my($key,$account,$name,$comment2,$deleter2,$date2) = split(/<>/,$_);
		if($account eq $pmfile && $key eq "1"){
			$new_flag = 0;
			if($in{'edit'}){
				if($comment2 eq $comment){ &error("�������e�̃R�����g�͓o�^�ł��܂���B"); }
				if($in{'up'}){
					$up_edit_flag = 1;
					next;
				}
				else{
					$comment2 = $comment;
					$date2 = $main::date;
				}
		}
		else{ $double_flag++; next; }
		}
		if($key eq "1"){ $i_word++; }
		$line2 .= qq($key<>$account<>$name<>$comment2<>$deleter2<>$date2<>\n);
	}
close($keyword_handler);

	# �ǉ�����s
	if($new_flag || $up_edit_flag){
		$line2_plus = qq(1<>$pmfile<>$pmname<>$comment<><>$main::date<>\n);
	}
$line2 = $line2_plus . $line2;

# �d���o�^�̏ꍇ
if($double_flag >= 2){ &error("���̃^�O (<a href=\"./tag-word-$enc_tag.html\">$tag</a>) �͓o�^�ς݂ł��B"); }

# �L�[���[�h�t�@�C������������
Mebius::Fileout("",$openfile2,$line2);

# ���b�N����
&unlock("tag$enc_tag") if($lockkey);

# �V�K�o�^�̏ꍇ�u�V���^�O�v�u�S�^�O�v���X�V
if($new_flag){
&make_newtag("",$i_word,$tag);
&make_alltag("","",$tag);
}

# �y�[�W�W�����v
$jump_sec = $auth_jump;
if($in{'edit'}){
$jump_url = "./tag-word-$enc_tag.html";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }
$finished_text = qq(�R�����g��ҏW���܂���);
}
else{
$jump_url = "${file}/tag-view";
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }
$finished_text = qq(�V�����^�O��o�^���܂���);
}


my $print = qq($finished_text�i<a href="$jump_url">���߂�</a>�j�B<br>);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �V���^�O���X�V
#-----------------------------------------------------------
sub make_newtag{

# �錾
my($type,$i_word,$tag) = @_;
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# ���b�N�J�n
&lock("newtag") if($lockkey);

# �ǉ�����s
$line3 = qq($i_word<>$tag<>$pmfile<>\n);
#$line3 = qq(1<>$tag<>$pmfile<>$pmname<>$comment<>\n);

# �V���^�O�t�@�C�����J��
my $openfile3 = "${auth_log_directory}newtag.cgi";
open(NEWTAG_IN,"<","$openfile3");
	while(<NEWTAG_IN>){
		my($num,$tag2,$account) = split(/<>/,$_);
		$i_newtag++;
		if($i_newtag > 500){ last; }
		if($tag2 eq $tag){ next; }
		$line3 .= $_;
	}
close(NEWTAG_IN);

# �V���^�O�t�@�C������������
Mebius::Fileout(undef,$openfile3,$line3);


# ���b�N����
&unlock("newtag") if($lockkey);

}

#-----------------------------------------------------------
# �S�^�O���X�V
#-----------------------------------------------------------
sub make_alltag{

# �錾
my($type,$i_word,$tag) = @_;
my($i);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# ���b�N�J�n
&lock("alltag") if($lockkey);

# �ǉ�����s
$line4 .= qq($tag\n);

# �S�^�O�t�@�C�����J��
my $openfile4 = "${auth_log_directory}alltag.cgi";
open(ALLTAG_IN,"<",$openfile4);
	while(<ALLTAG_IN>){
		$i++;
		if($i > 10000){ last; }
		chomp;
		if($_ eq $tag){ next; }
		$line4 .= qq($_\n);

	}
close(ALLTAG_IN);

# �S�^�O�t�@�C������������
Mebius::Fileout(undef,$openfile4,$line4);

# ���b�N����
&unlock("alltag") if($lockkey);

}

1;
