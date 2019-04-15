
package main;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_avallresdiary{

# �Ǐ���
my($file);

#�����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# ��{�^�C�g��
$main_title = "�V�����X�i���L�j";

# CSS��`
$css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25;}
li{line-height:1.5;}
table,th,tr,td{border-style:none;}
table{font-size:90%;width:100%;}
th{text-align:left;padding:0.5em 1.0em 0.5em 0.0em;}
th.to{width:20%;}
th.name{width:20%;}
th.sub{width:25%;}
th.date{width:9em;}
td{padding:0.2em 1.0em 0.5em 0.0em;vertical-align:top;}
span.guide{font-size:90%;color:#080;}
div.comment{width:30em;line-height:1.4;word-wrap;break-word;}
);

# �^�C�g����`
$sub_title = "$main_title - $title";
$head_link3 = qq(&gt; $main_title);
if($in{'word'} ne ""){
$sub_title = "�h$in{'word'}�h�Ō��� - $main_title - $title";
$head_link3 = qq(&gt; <a href="./aview-alldiary.html">$main_title</a> );
$head_link4 = qq(&gt; �h$in{'word'}�h�Ō��� );
}


# ���L�ꗗ���擾
&auth_avallresdiary_newlist_diary();

# �i�r
my $link2 = "${pmfile}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">�����̃v���t�B�[���֖߂�</a>);

# �t�H�[�����擾
my($form) = &auth_avallresdiary_get_form;

# HTML
my $print = <<"EOM";
$footer_link
<h1>$main_title - $title</h1>
$navilink
$form
<h2>�ꗗ</h2>
$newdiary_index
$footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

#-----------------------------------------------------------
# �����t�H�[��
#-----------------------------------------------------------
sub auth_avallresdiary_get_form{

my $form .= qq(
<h2>$main_title���猟��</h2>
<form action="$action">
<div>
<input type="hidden" name="mode" value="aview-allresdiary">
<input type="text" name="word" value="$in{'word'}">
<input type="submit" value="$main_title���猟������">�@
<span class="guide">���u���L�薼�v�u�M���v�u�A�J�E���g���v���猟�����܂��B</span>
</div>
</form>
);

return($form);

}

#������������������������������������������������������������
# �S�����o�[�̐V�����X�i���L�j
#������������������������������������������������������������

sub auth_avallresdiary_newlist_diary{

my($i,$max);

# �ő�\���s��
$max = 50;
if($k_access){ $max = 25; }
#if($myadmin_flag){ $max = 500; }

my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

# ���s�C���f�b�N�X��ǂݍ���
open(NEWDIARY_IN,"<","${auth_log_directory}newresdiary.cgi");
	while(<NEWDIARY_IN>){
	chomp;
	my($key,$file,$sub,$account,$name,$account2,$name2,$comment,$date,$res) = split(/<>/,$_);
	if($key eq "0"){ next; }

	if($in{'word'} ne ""){
	if(index($name,$in{'word'}) < 0 && index($name2,$in{'word'}) < 0 && index($account,$in{'word'}) < 0 && index($account2,$in{'word'}) < 0 && index($sub,$in{'word'}) < 0){ next; }
	}

	my $link1 = qq($account/);
	my $link2 = qq($account2/);

	#<td><a href="$link1">$name - $account</a></td>

	$newdiary_index .= qq(<tr><td><a href="$account/d-$file">$sub</a> ( <a href="$account/d-$file#S$res">Re: $res</a> ) </td><td><a href="$link2">$name2 - $account2</a></td><td><div class="comment">$comment</div></td><td>$date</td></tr>);

	$i++;
			if($i >= $max){ last; }

	}
close(NEWDIARY_IN);

#<th class="to">���L�� ( To )</th>

if($newdiary_index){
$newdiary_index = qq(
<table summary="�V���`���ꗗ"><tr><th class="sub">���L��</th><th class="name">���e�ҁi From �j</th><th>�R�����g</th><th class="date">����</th></tr>\n
$newdiary_index
</table>
);
}

}

1;
