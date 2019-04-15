
package main;
use Mebius::Text;
use Mebius::Export;

#-----------------------------------------------------------
# �T�C�g�S�̂̐V�����X�g
#-----------------------------------------------------------
sub main_newlist{

# �Ǐ���
my($type) = @_;
my($print,$not_pagelinks_flag,$max_pagelinks,$page_links,$navi_links,$domain_links,$allsearch_form,$allsearch_plustype);
my($plustype_all);
local($i,$file,$h1_title,$ptype,$guide1,$new_links,$category_flag,$line);
our($css_text,$submode3);

	# ���[�h����
	if($type =~ /Admin-view/){
		$plustype_all .= qq( Admin-view);
	}

# �\���ő吔
local $view_max = 100;
local $kview_max = 20;

# �y�[�W�ő吔
local $page_max = 5;

# CSS��`
$css_text .= qq(
table.newlist th,
table.newlist tr,
table.newlist td{vertical-align:top;}
table.newlist{font-size:90%;margin-top:1.0em;width:100%;}
th{padding-right:1em;text-align:left;padding:0.5em 0.0em;}
th.sub{width:40%;}
th.bbs{width:20%;}
td{padding:0.3em 1.0em 0.3em 0.0em;}
ul{line-height:1.5em;font-size:90%;}
div.new_links{display:inline;background-color:#ffd;padding:0.4em 1.2em;border:solid 1px #f93;line-height:2.0em;font-size:90%;}
div.domain_links{display:inline;background-color:#dee;padding:0.4em 1.2em;border:solid 1px #5bb;margin-left:1em;line-height:2.0em;font-size:90%;}
div.cate_links{background-color:#eee;padding:0.4em 1.0em;border:solid 1px #aaa;font-size:90%;margin:1em 0em;}
span.none{display:none;}
a.res{color:#080;}
div.select_links{margin:0.5em 0em;}
div.navi_links{margin:1.0em 0em;}
div.page_links{margin:0.5em 0em;}
div.guide1{margin:1.0em 0em;color:#060;font-size:90%;}
div.allsearch_form{margin:0.5em 0em;}
input.allsearch_input_newlist{font-size:100%;}
input.allsearch_submit_newlist{font-size:100%;}
i{background:#f90;}
);


# �g�єł̏���
if($submode2 eq "k"){
&kget_items();
$view_max = $kview_max;
}


# �����^�C�v�ɂ��G���[
if($submode2 ne "k" && $submode2 ne "p"){ &error("�y�[�W�����݂��܂���B"); }


# ���݂̃y�[�W�����`
$submode3 =~ s/[^0-9a-z]//g;
if($submode3 =~ /[^0-9]/){ $category_flag = 1; } 
if($submode3 eq ""){ &error("�y�[�W�����w�肵�Ă��������B"); }

	# �A�N�Z�X�U�蕪��
	if($submode1 ne "allsearch"){
			if($submode2 eq "k"){
			$divide_url = "http://$server_domain/_main/$submode1-p-$submode3.html";
				# �g�є�URL���܂Ƃ߂�
				Mebius::Redirect(undef,"http://$server_domain/_main/$submode1-p-$submode3.html",301);
				#if($device_type eq "desktop" && $submode3 eq "1"){ main::divide($divide_url,"mobile"); }
			}
			elsif($submode2 eq "p"){
			$divide_url = "http://$server_domain/_main/$submode1-k-$submode3.html";
				#if($device_type eq "mobile" && $submode3 eq "1"){ main::divide($divide_url,"desktop"); }
			}
	}

# �J�e�S���擾
if($submode1 eq "newres" || $submode1 eq "newthread"){ ($cate_links) = &get_category(); }

# �^�C�g����`�A���X�g��`
my($file) = &get_title();

# �h���C���؂�ւ������N���擾
($domain_links) = &newlist_domain_links();

# �S�������[�h
if($ptype eq "allsearch"){
($line,$guide1) = Mebius::Newlist::allsearch("$main::ktype",$main::in{'word'},$main::in{'sc'},$main::in{'sc2'});
$not_pagelinks_flag = 1;
}

# �V���^�O���擾
elsif($ptype eq "newtag"){
my($plustype) = " SEARCH" if ($main::ch{'word'});
($line) = Mebius::Newlist::tag("INDEX$plustype$main::ktype",$main::in{'word'});
$allsearch_plustype .= qq( TAG);
}

# �V�����L�����擾
elsif($ptype eq "newthread"){
($line) = Mebius::Newlist::threadres("INDEX THREAD$ktype $plustype_all",$main::in{'word'},"",$main::submode3);
$allsearch_plustype .= qq( THREAD);
}

# �V�������X���擾
elsif($ptype eq "newres"){
($line) = Mebius::Newlist::threadres("INDEX RES Buffer$ktype $plustype_all",$main::in{'word'},"",$main::submode3);
$allsearch_plustype .= qq( RES);
}

	# �ő僌�X���B���X���b�h���擾
	elsif($ptype eq "maxres"){
		($line) = Mebius::Newlist::Maxres("Get-index",$main::in{'word'},"",$main::submode3);
	}

	# �V�������G����
	elsif($ptype eq "newpaint"){
		($line,$guide1) = Mebius::Newlist::Paint("Get-index Justy",$main::in{'word'},"",$main::submode3);
	}

	elsif($ptype eq "newsupport"){ &get_list2($file); }
	elsif($ptype eq "rankspt"){ &get_list3($file); }

	# ���݃����L���O���擾
	elsif($ptype eq "rankgold"){
		($line,$guide1,$max_pagelinks) = Mebius::Newlist::goldranking("GOLD INDEX$main::ktype","",$main::submode3);
	}

	# ��݃����L���O���擾
	elsif($ptype eq "ranksilver"){
		($line,$guide1,$max_pagelinks) = Mebius::Newlist::goldranking("SILVER INDEX$main::ktype","",$main::submode3);
	}

	elsif($ptype eq "editmemo"){
		my($edit_memo) = &EditMemoList({ TypeGetIndex => 1 , MaxViewIndex => $view_max , NowPageNumber => $submode3});
		$line = $edit_memo->{'index_line'};

	}
	elsif($ptype eq "allpost"){ &get_list_allpost(); }
	elsif($ptype eq "rankpv"){ &get_list_pv("Normal"); }
	elsif($ptype eq "rankspv"){ &get_list_pv("Search"); }
	elsif($ptype eq "echeck"){
		$main::noindex_flag = 1;
		($line) = Mebius::Newlist::threadres("INDEX ECHECK $ktype $plustype_all",undef,undef,$main::submode3);
	}
	elsif($ptype eq "other"){
		$main::noindex_flag = 1;
		($line) = Mebius::Newlist::threadres("INDEX From-other-site-file $ktype $plustype_all",undef,undef,$main::submode3);
	}

else{ main::error("�y�[�W�����݂��܂���B"); }
	
# �t�H�[�J�X�𓖂Ă�
$main::body_javascript = qq( onload="document.ALLSEARCH_NEWLIST.word.focus()");

# �S�����t�H�[�����擾
if($ptype =~ /^(allsearch|newres|newthread|newtag)$/){
($allsearch_form) = Mebius::Newlist::allsearch_form("CSS1 SELECT-CHECKBOX LIMIT-CHECKBOX$allsearch_plustype$main::ktype",$main::in{'word'},$main::in{'sc'},$main::in{'sc2'},"NEWLIST");
}

# �K�C�h�����𐮌`
if($guide1){ $guide1 = qq(<div class="guide1">$guide1</div>); }
if($allsearch_form){ $allsearch_form = qq(<div class="allsearch_form">$allsearch_form</div>); }

# �y�[�W�؂�ւ������N���擾
if(!$not_pagelinks_flag){ ($page_links) = &page_links("",$max_pagelinks); }


# �i�r�Q�[�V���������N
if(!$kflag){ $navi_links = qq(<a href="/">�s�n�o�y�[�W�ɖ߂�</a>); }

# HTML ( �o�b�� )
if(!$kflag){
$print = qq(

<h1>$h1_title</h1>
<div class="navi_links">$navi_links</div>
<div class="select_links">$new_links</div>
$allsearch_form
$guide1
$cate_links
$line
$page_links
$domain_links

);
}

# HTML ( �g�є� )
else{
$print = qq(
<h1>$h1_title</h1>
$allsearch_form
$guide1
$line
$khrtag
<div style="font-size:small;">
$new_links
$navi_links

$cate_links
$domain_links
</div>
$page_links
);

}

# �Ǘ����[�h�p��URL�ϊ�
if($admin_mode){ ($print) = Mebius::Adfix("Url",$print); }

# �����o��
Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}

#-----------------------------------------------------------
# �J�e�S���؂�ւ������N
#-----------------------------------------------------------
sub get_category{

# �Ǐ���
my($i,$cate_links);

my @category = (
"aura=������=1",
"poemer=��=1",
"novel=����=1",
"diary=���L��=1",
"soudann=���k=1",
"shakai=�Љ�=1",
"nenndai=�G�k�P=1",
"zatudann2=�G�k�Q=2",
"chiiki=�n��=1",
"music=���y=2",
"gokko=������=2",
"anicomi=�A�j��/����=2",
"game=�Q�[��=2",
"narikiri=�Ȃ肫��=2",
"etc=�d�s�b=2",
"mebi=���r=1"
);

foreach(@category){
$i++;
if($i >= 2){ $cate_links .= qq( - ); }

my($category,$title,$domain) = split(/=/,$_);

my($url);
if($domain eq "1"){ $url = "http://aurasoul.mb2.jp/"; }
else{ $url = "http://mb2.jp/"; }

if($category eq $submode3){ $cate_links .= qq( $title ); $category_title = qq($title�J�e�S��); }
else{ $cate_links .= qq( <a href="${url}_main/$submode1-$submode2-$category.html">$title</a> );}
}
$cate_links = qq(<div class="cate_links">$cate_links</div>);

return($cate_links);

}

#-----------------------------------------------------------
# �^�C�g����`�E�t�@�C����`�E���[�h�ؑփ����N
#-----------------------------------------------------------
sub get_title{

# �Ǐ���
my($i,$hit,$ptitle,@new_links,$file);

# �e��y�[�W �؂�ւ������N
@new_links = (
"���r�E�X�S����=allsearch==����=no_menu",
"�V���^�O=newtag==�^�O",
"�V���L��=newthread==�L��",
"�V�����X=newres==���X",
"�V���G=newpaint==�G=hidden",
"�V�������ˁI=newsupport=_sinnchaku/all_newsupport=�����ˁI",
"�V������=editmemo=_backup/memoedit_backup=����",
"�����X��=allpost==�����X",
"�l�C�L��=rankspt=_sinnchaku/rank_support=�l�C",
"���݃����L���O=rankgold==����",
"PV�����L���O=rankpv=_sinnchaku/rank_pv=PV1=no_menu",
"PV�����L���O(����)=rankspv=_sinnchaku/rank_spv=PV2=no_menu",
"���ӓ��e=echeck==����=nofollow",
"�O���o�R=other==�O��=nofollow"
);

#"�ő僌�X�B���L��=maxres==�ő僌�X",

#"��݃����L���O=ranksilver==���",


	# �e��U�蕪��
	foreach(@new_links){

		$i++;

		my($title,$type,$file2,$title2,$type2) = split(/=/);
		my($nofollow);
		my $linkname = $title;

			# �Ǘ����[�h�ł̂ݕ\������ꍇ
			if($type =~ /^(other)$/ && !$main::admin_mode){ next; }

			if($title2){ $linkname = $title2; }
			if($type eq $submode1){
					if($hit >= 1){ $new_links .= qq( - ); }
				$new_links .= qq($linkname\n);
				$ptitle = $title;
				$ptype = $type;
				$ptype2 = $type2;
				$file = "${int_dir}${file2}.cgi";
			}

			else{

					# �����N���{�b�g������ǉ�
					if($type2 eq "no_menu"){ next; }

					# �����N���{�b�g������ǉ�
					if($type2 eq "nofollow"){ $nofollow = qq( rel="nofollow"); }

					if($hit >= 1){ $new_links .= qq( - ); }
					$new_links .= qq(<a href="$type-$submode2-1.html"$nofollow>$linkname</a>\n);

			}
		$hit++;

	}

$new_links = qq(<div class="new_links">$new_links</div>);

# �^�C�g����`
my($page);
if($category_title){ $page = $category_title; }
else{ $page = $server_domain; }

$sub_title = "$ptitle | $page";
if($submode3 >= 2){ $sub_title = "$submode3 | $ptitle | $page"; }
$head_link2 = qq( &gt; <a href="http://$server_domain/">$server_domain</a> );
$head_link3 = qq( &gt; $ptitle );
$h1_title = "$ptitle ( $page )";

return($file);

}

#-----------------------------------------------------------
# �h���C���؂�ւ������N
#-----------------------------------------------------------
sub newlist_domain_links{

# �Ǐ���
my($i,$domain_links);
our(%in,$postbuf_query_esc,$mode);

# �h���C���؂�ւ������N
	foreach(@domains){
$idomain++;
		if($idomain >= 2){ $domain_links .= qq( - ); }
		if($_ eq $server_domain){ $domain_links .= qq($_); }
		else{
			if($in{'word'}){ $domain_links .= qq(<a href="http://$_/_main/?$postbuf_query_esc">$_</a>); }
			else{ $domain_links .= qq(<a href="http://$_/_main/$mode.html">$_</a>); }
		}
	}
$domain_links = qq(<div class="domain_links">$domain_links</div>);

return($domain_links);

}

#-----------------------------------------------------------
# �y�[�W�؂�ւ������N
#-----------------------------------------------------------
sub page_links{

# �錾
my($type,$max_pagelinks) = @_;
my($page_links);
my($page_max) = our($page_max);

if($max_pagelinks){ $page_max = $max_pagelinks; }

if($category_flag || $submode1 eq "allpost" || $submode1 eq "newtag"){ return; }

for(1..$page_max){
if($_ eq $submode3){ $page_links .= qq($_ ); }
else{ $page_links .= qq(<a href="$submode1-$submode2-$_.html">$_</a> ); }
}
$page_links = qq(<div class="page_links">$page_links</div>);
return($page_links);

}


#-----------------------------------------------------------
# ���X�g���e���擾�Q �i �V�������ˁI �j
#-----------------------------------------------------------
sub get_list2{

# �Ǐ���
my($file) = @_;
my($flag);

# CSS��`��ǉ�
$css_text .= qq(
table.new_crap{word-wrap:break-word;}
table.new_crap th.sub{width:auto;}
table.new_crap th.name{width:10em;}
table.new_crap th.bbs{width:13em;}
table.new_crap th.date{width:8em;}
div.comment{width:20em;word-wrap:break-word;}
);


# �\�����X�g���`�i�O�j
if($kflag){ $line .= qq(<ul>); }
else{ $line .= qq(<table summary="$ptitle�̃��X�g" class="new_crap newlist"><tr><th class="sub">�L����</th><th class="bbs">�f����</th><th>�M��</th><th class="comment">�R�����g</th></tr>\n); }

# �t�@�C���ǂݍ���
open(IN,"$file");
while(<IN>){
$i++;

if(!$category_flag){
if($i < ($submode3 - 1)*$view_max){ next; }
if($i >= $view_max + $view_max * ($submode3 - 1)){ last; }
}

chomp;
my($key,$moto,$title,$no,$sub,$handle,$comment,$No,$restime,$date,$cate) = split(/<>/);
if($category_flag && $submode3 ne $cate){ next; }
$flag = 1;
if($kflag){ $line .= qq(<li><a href="/_$moto/$no.html">$sub</a> - <a href="/_$moto/">$title</a> - $date</li>); }
else{ $line .= qq(<tr><td><a href="/_$moto/$no.html">$sub</a></td><td><a href="/_$moto/">$title</a></td><td>$handle</td><td><div class="comment">$comment</div></td></tr>\n); }
}
close(IN);

# �\�����X�g���`�i��j
if($kflag){ $line .= qq(</ul>); }
else{ $line .= qq(</table>); }

# �q�b�g���Ȃ��ꍇ
if(!$flag){ &error("�\\��������e������܂���B"); }

}

#-----------------------------------------------------------
# ���X�g���e���擾�R �i �l�C�L�� �j
#-----------------------------------------------------------
sub get_list3{

# �Ǐ���
my($file) = @_;

# CSS��`��ǉ�
$css_text .= qq(
th.num{}
td.num{}
);

# �\�����X�g���`�i�O�j
if($kflag){ $line .= qq(<ul>); }
else{ $line .= qq(<table summary="$ptitle�̃��X�g" class="newlist"><tr><th class="sub">�L����</th><th class="bbs">�f����</th><th class="num">�����ˁI</th></tr>\n); }

# �t�@�C���ǂݍ���
open(IN,"$file");
while(<IN>){
$i++;

if($i < ($submode3 - 1)*$view_max){ next; }
if($i >= $view_max + $view_max * ($submode3 - 1)){ last; }
chomp;
my($key,$num,$moto,$title,$no,$sub) = split(/<>/,$_);

if($kflag){ $line .= qq(<li><a href="/_$moto/$no.html">$sub</a> - <a href="/_$moto/">$title</a> ($num�����ˁI)</li>); }
else{ $line .= qq(<tr><td><a href="/_$moto/$no.html">$sub</a></td><td><a href="/_$moto/">$title</a></td><td class="num">$num��</td></tr>\n); }
}
close(IN);

# �\�����X�g���`�i��j
if($kflag){ $line .= qq(</ul>); }
else{ $line .= qq(</table>); }

}

use strict;

#-----------------------------------------------------------
# ���X�g���e���擾�P �i �L���������� �j
#-----------------------------------------------------------
sub EditMemoList{

# �Ǐ���
my($use) = @_;
my($flag,$FILE1,@renew_line,%self,$i);

# �f�o�C�X�����擾
my($use_device) = Mebius::my_use_device();

# �t�@�C��
my($init_directory) = Mebius::BaseInitDirectory();
my $file = "${init_directory}_sinnchaku/new_edit_memo.log";

	# �\�����X�g���`�i�O�j
	if($use_device->{'type'} eq "Mobile"){ $self{'index_line'} .= qq(<ul>); }
	else{ $self{'index_line'} .= qq(<table class="newlist"><tr><th class="sub">�L����</th><th class="bbs">�f����</th><th class="name">�M��</th><th class="date">����</th></tr>\n); }


# �t�@�C���ǂݍ���
open($FILE1,"<$file");

	# �t�@�C�����b�N
	if($use->{'TypeRenew'}){ flock(1,$FILE1); }

	# �t�@�C����W�J
	while(<$FILE1>){

		# �Ǐ���
		my($mark);

		$i++;

		# �s�𕪉�
		chomp;
		my($key,$lasttime,$dat,$sub,$title,$moto2,$thread_number2,$before,$after,$name,$id,$trip,$host2,$age2,$number,$account) = split(/<>/,$_);

			# ���C���f�b�N�X�擾�p
			if($use->{'TypeGetIndex'}){

					if($i < ($use->{'NowPageNumber'} - 1)*$use->{'MaxViewIndex'}){ next; }
					if($i >= $use->{'MaxViewIndex'} + $use->{'MaxViewIndex'} * ($use->{'NowPageNumber'} - 1)){ last; }

					if($after eq ""){ $mark = qq( <strong>����</strong> ); }

				$flag = 1;

					if($use_device->{'type'} eq "Mobile"){
						$self{'index_line'} .= qq(<li><a href="/_$moto2/$thread_number2.html">$sub</a> $mark ( <a href="/_$moto2/${thread_number2}_memo.html#HISTORY" rel="nofollow">������</a> ) - <a href="/_$moto2/">$title</a> - $name - $dat</li>);
					}
					else{
						$self{'index_line'} .= qq(<tr><td><a href="/_$moto2/$thread_number2.html">$sub</a> $mark ( <a href="/_$moto2/${thread_number2}_memo.html#HISTORY" rel="nofollow">������</a> ) </td><td><a href="/_$moto2/">$title</a></td><td>$name</td><td>$dat</td></tr>\n);
					}

			}

			# ���t�@�C���X�V�p
			if($use->{'TypeRenew'}){
					if($use->{'TypeNewLine'}){
						if($thread_number2 eq $use->{'NewThreadNumber'}){ next; }
					}
				push(@renew_line,"$key<>$lasttime<>$dat<>$sub<>$title<>$moto2<>$thread_number2<>$before<>$after<>$name<>$id<>$trip<>$host2<>$age2<>$number<>$account<>\n");
			}

	}
close($FILE1);

	# �t�@�C���X�V
	if($use->{'TypeRenew'}){

			# �V�����s��ǉ�
			if($use->{'TypeNewLine'}){
				my $time = time;
				my($access) = Mebius::my_access();
				my($gethost) = Mebius::GetHostWithFile();
				my($nowdate) = Mebius::now_date();
				my($encid) = main::id();

	unshift(@renew_line,"1<>$time<>$nowdate<>$use->{'NewSubject'}<>$use->{'NewTitle'}<>$use->{'NewMoto'}<>$use->{'NewThreadNumber'}<>$use->{'NewBeforeText'}<>$use->{'NewAfterText'}<>$use->{'NewHandle'}<>$encid<>$use->{'NewTrip'}<>$gethost<>$access->{'multi_user_agent_escaped'}<>$main::cnumber<>$main::myaccount{'file'}<>\n");
			}

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file,@renew_line);
	}


	# �C���f�b�N�X���`
	if($use->{'TypeGetIndex'}){
		if($use_device->{'type'} eq "Mobile"){ $self{'index_line'} .= qq(</ul>); } else { $self{'index_line'} .= qq(</table>); }
			# �q�b�g���Ȃ��ꍇ
			#if(!$flag){ &error("�\\��������e������܂���B"); }
	}


return(\%self);

}

no strict;
use Time::Local;

#-----------------------------------------------------------
# ���X�g���e���擾�V �i �����X�� �j
#-----------------------------------------------------------

sub get_list_allpost{

my($max,$i);
our($myadmin_flag,$submode3);
my($my_account) = Mebius::my_account();

	if($my_account->{'admin_flag'}){
			if($submode3 eq "all"){
				$max = 356*5;
			} else {
				$max = 4*7;
			}
	} else {
		$max = 7;
	}


# �N����`
my $nowtime = $time;

# CSS��`
$css_text .= qq();

# �\�����X�g���`�i�O�j
if($kflag){  }
else{ $line .= qq(<table summary="$ptitle�̃��X�g" class="newlist"><tr><th class="date">���t</th><th>�����X��</th><th>��������</th><th>����������</th></tr>\n); }

	# �W�J
	for(1...$max){
		$i++;
		my($day,$month,$year) = (localtime($nowtime))[3..5];
		$year += 1900;
		$month += 1;
		my($res,$length,$average,$wday) = get_allpost("${year}_${month}_${day}");

		# �j��
		my($view_wday);
			if($wday eq "��"){ $view_wday = qq((<span style="color:#f00;">$wday</span>)); }
			elsif($wday eq "�y"){ $view_wday = qq((<span style="color:#00f;">$wday</span>));}
			elsif($wday){ $view_wday = qq((<span style="color:#080;">$wday</span>)); }


		if(!$res){ last; }
		if($kflag){
			#if($i >= 2){ $line .= qq(<hr$main::xclose>); }
			$line .= qq(<div style="background:#ddd;$main::ktextalign_center_in">${year}�N ${month}��${day}�� $view_wday</div>\n);
			$line .= qq(<div style="$main::kpadding_normal_in">$res���X / $length���� / ����$average����</div>\n);
		}
		else{ $line .= qq(<tr><td class="left">${year}�N ${month}��${day}�� $view_wday</td><td>$res</td><td>$length</td><td>$average</td></tr>\n); }
		$nowtime -= 1*24*60*60;
	}

	# �\�����X�g���`�i��j
	if($kflag){  } else { $line .= qq(</table>); }

}



#-----------------------------------------------------------
# ���X�g���e���擾�V�@�i �����X�t�@�C�����擾 �j
#-----------------------------------------------------------
sub get_allpost{

# �錾
my($file) = @_;

open(ALLPOST_IN,"${int_dir}_reslength/$file.cgi");
my $top = <ALLPOST_IN>; chomp $top;
my($res,$length,$average,$wday) = split(/<>/,$top);
close(ALLPOST_IN);

return($res,$length,$average,$wday);

}

#-----------------------------------------------------------
# ���X�g���e���擾�W �i �o�u�����L���O �j
#-----------------------------------------------------------
sub get_list_pv{

# �Ǐ���
my($type) = @_;
my(@line,$viewpv,$pv_handler,$file);

if($type =~ /Normal/){ $file = "${main::int_dir}_sinnchaku/rank_pv.log"; }
elsif($type =~ /Search/){ $file = "${main::int_dir}_sinnchaku/rank_spv.log"; }
else{ return(); }

# CSS��`��ǉ�
$css_text .= qq(
th.num{}
td.num{}
);

# �\�����X�g���`�i�O�j
if($kflag){ $line .= qq(<ul>); }
else{ $line .= qq(<table summary="$ptitle�̃��X�g" class="newlist"><tr><th class="sub">�L����</th><th class="bbs">�f����</th></tr>\n); }

# �t�@�C���ǂݍ���
open($pv_handler,"$file");
chomp(my $top1 = <$pv_handler>); 
while(<$pv_handler>){ push(@line,$_); }
close($pv_handler);

# �t�@�C���ǂݍ���
foreach(@line){
$i++;

if($i < ($submode3 - 1)*$view_max){ next; }
if($i >= $view_max + $view_max * ($submode3 - 1)){ last; }

chomp;
my($key,$num,$moto,$title,$no,$sub) = split(/<>/,$_);

if($admin_mode || $myadmin_flag >= 5){ $viewpv = qq( ( ${num} )); }
if($kflag){ $line .= qq(<li><a href="/_$moto/$no.html">$sub</a> - <a href="/_$moto/">$title</a></li>); }
else{ $line .= qq(<tr><td><a href="/_$moto/$no.html">$sub</a>$viewpv</td><td><a href="/_$moto/">$title</a></td></tr>\n); }
}

# �\�����X�g���`�i��j
if($kflag){ $line .= qq(</ul>); }
else{ $line .= qq(</table>); }

}


#-----------------------------------------------------------
# ���X�g���e���擾�X �i ���ӓ��e �j
#-----------------------------------------------------------
sub get_list_echeck{

# �Ǐ���
my($flag,$i,$file);

# ���{�b�g����
$main::noindex_flag = 1;

$file = "${main::int_dir}_sinnchaku/rcevil.log";

# CSS��`��ǉ�
$css_text .= qq(
th.type{width:4.5em;}
td.num{}
td.sub{line-height:1.4em;}
div.comment{word-break:break-word;width:50em;line-height:1.2em;}
del{color:#555;}
);

# �Ď��L�[���[�h
my @keywords = ('���A�h','�d�b','�莆','����','�Z��','�{��','��','���[��','�����[�ҁ[','�W�F�[�s�[','tel','�h�b�g','�ǂ���');
my @keywords2 = ('����','�E�U��','������','�Z�b�N�X');

# �\�����X�g���`�i�O�j
if($kflag){ $line .= qq(<ul>); }
else{ $line .= qq(<table summary="$ptitle�̃��X�g" class="newlist"><tr><th class="sub">�e��f�[�^</th><th>�R�����g</th></tr>\n); }

# �t�@�C���ǂݍ���
open(IN,"$file");
while(<IN>){
my($mark,$comline);
$i++;

if(!$category_flag){
if($i < ($submode3 - 1)*$view_max){ next; }
if($i >= $view_max + $view_max * ($submode3 - 1)){ last; }
}

chomp;
my($key,$typename,$title,$url,$sub,$handle,$comment,$resnumber,$lasttime,$dat,$category,undef,$echeck_flag2) = split(/<>/);
my($resurl,$moto2);

$resurl = $url;
if($url =~ /_([a-z0-9]+)\//){ $moto2 = $1; }

# �t�q�k���`
if($admin_mode){
$url =~ s/http:\/\/([a-z0-9\.]+)\/_([a-z0-9]+)\/([0-9]+)(|_data|_memo)\.html(|\-)($|([0-9,]+))/http:\/\/$1\/jak\/$2.cgi?mode=view&amp;no=$3/;
$resurl = "$url#S$6";
$moto2 = $2;
}

	# �R�����g���`
	foreach $tmp (split(/<br$xclose>/,$comment)){
	my($hit);

	if($moto2 ne "cnr"){
	foreach $keyword (@keywords){
	($hit) += ($tmp =~ s/(\Q$keyword\E)/<strong class="red">$1<\/strong>/g);
	}
	}

	foreach $keyword2 (@keywords2){
	($hit) += ($tmp =~ s/(\Q$keyword2\E)/<strong class="red">$1<\/strong>/g);
	}

	if($hit){ $comline .= qq($tmp<br$xclose>); }
	}
	$comment = $comline;

	if($echeck_flag2){ $comment = $echeck_flag2; }


if($sub eq ""){ $sub = "�y�[�W"; }
if($key eq "2"){ $comment = qq(<del>$comment</del>); }
if($No eq ""){ $No = 0; }
if($kflag){ $line .= qq(<li>$typename�H<a href="$url">$sub</a>   - <a href="/_$moto2/">$title</a> - $name - $dat</li>); }
else{ $line .= qq(<tr><td class="sub valign-top"><a href="$url">$sub</a> <a href="$resurl">( $handle )</a> <br$xclose> <a href="/_$moto2/">$title</a><br$xclose>$dat</td><td class="valign-top"><div class="comment">$comment</div></td></tr>\n); }
}
close(IN);

# �\�����X�g���`�i��j
if($kflag){ $line .= qq(</ul>); } else { $line .= qq(</table>); }

}


# �p�b�P�[�W�錾
use strict;
package Mebius::Newlist;
use Mebius::Export;


#-----------------------------------------------------------
# ���X�g���e���擾�S �i ���݃����L���O �j
#-----------------------------------------------------------
sub goldranking{

# �Ǐ���
my($type,$maxview_index,$nowpage_number,$postdata) = @_;
my($pgold,$paccount,$phandle,$pencid,$pkaccess_one,$pkaccess) = split(/<>/,$postdata);
my($pkaccesses) = ("$pkaccess_one-$pkaccess") if($pkaccess_one && $pkaccess);
my($init_directory) = Mebius::BaseInitDirectory();
my($use,@line,@renewline,$index_line,$logfile,$FILE1,$i,$top1,$maxline_renew,$under_gold);
my($still_flag,$toper_gold,$under_gold,$maxrenew_index,$guide1,$your_rank,$hit_index,$max_pagelinks,%self,$file1);
our($xclose);

	# �t�@�C���X�V�����ŁA�K�v�ȓ��̓f�[�^������Ȃ��ꍇ
	if($type =~ /RENEW/){
			if($pgold eq ""){ return(); }
			if($pgold < 50){ return(); }
			if($paccount eq "" && $pkaccesses eq ""){ return(); }
	}

	# CSS���`
	if($type =~ /INDEX/){
		$main::css_text .= qq(i{background:#f90;});
	}

	# �P�y�[�W������̍ő�h�\���h�s���̐ݒ�
	if(!$maxview_index){
			if($type =~ /MOBILE/){ $maxview_index = 50; }
			else{ $maxview_index = 100; }
	}

# �ő�h�o�^�h�s���̐ݒ�
$maxrenew_index = 1000;

# �y�[�W�߂���̍ő�y�[�W��
$max_pagelinks = 10;

	# �t�@�C����`�A�^�C�v���Ȃ��ꍇ�͂��̂܂܃��^�[��
	if($type =~ /GOLD/){ $file1 = "${init_directory}_sinnchaku/goldranking.log"; }
	elsif($type =~ /SILVER/){ $file1 = "${init_directory}_sinnchaku/silverranking.log"; }
	else{ return(); }

# CSS��`��ǉ�
$main::css_text .= qq(
.your_rank{font-size:150%;font-weight:bold;color:#f00;}
th.rank{width:5%;}
);

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		$self{'f'} = open($FILE1,"+<",$file1) || &main::error("�t�@�C�������݂��܂���B");
	}
	else{

		$self{'f'} = open($FILE1,"+<",$file1);

			# �t�@�C�������݂��Ȃ��ꍇ
			if(!$self{'f'}){
					# �V�K�쐬
					if($type =~ /RENEW/){
						Mebius::Fileout("Allow-empty",$file1);
						$self{'f'} = open($FILE1,"+<",$file1);
					}
					else{
						return(\%self);
					}
			}

	}

	# �t�@�C�����b�N
	if($type =~ /RENEW/){ flock($FILE1,2); }

# �g�b�v�f�[�^�𕪉�
$top1 = <$FILE1>; chomp $top1;
my($tkey,$tlasttime,$tres,$ttoper_gold,$tunder_gold) = split(/<>/,$top1);

	# �t�@�C�����X�V����ꍇ�́A�g�b�v�f�[�^�ɑ΂��鏈��
	if($type =~ /RENEW/){

		# �Œ჉���J�[�����ݖ��������Ȃ��ꍇ�A���t�@�C�����ő�o�^���ɋ߂��ꍇ�A�t�@�C���n���h������ă��^�[��
		if($pgold < $tunder_gold && $tres >= $maxrenew_index - 5){ close($FILE1); return(); }

	}

	# �t�@�C����W�J���Ĕz��ɑ��
	while(<$FILE1>){ push(@line,$_); }

	# �擾�����C���f�b�N�X�z���W�J
	foreach(@line){

	# ���E���h�J�E���^
	$i++;

	# �Ǐ���
	chomp;
	my($view_encid2,$yourrank_flag,$yourrank_class);

	# ���̍s�𕪉�
	my($key2,$gold2,$account2,$handle2,$encid2,$kaccesses2) = split(/<>/,$_);

		# �L�[���Ȃ���Ύ��񏈗���
		if($key2 ne "1"){ next; }

		# ���t�@�C���X�V�p�̏���
		if($type =~ /RENEW/){

			# �o�^�ő吔
			if($i > $maxrenew_index){ last; }

			# �����̓o�^���������ꍇ�A���ݖ������X�V�i�A�J�E���g�j
			if($paccount){
				if($account2 && $account2 eq $paccount){ $gold2 = $pgold; $still_flag = 1; }
			}
	
			# �����̓o�^���������ꍇ�A���ݖ������X�V�i�ő̎��ʔԍ��j
			elsif($pkaccesses){
				if($kaccesses2 && $kaccesses2 eq $pkaccesses){ $gold2 = $pgold; $still_flag = 1; }
			}

		# �C���f�b�N�X�̍X�V�s��ǉ�
		push(@renewline,"$key2<>$gold2<>$account2<>$handle2<>$encid2<>$kaccesses2<>\n");

			# �����L���O���̍ō�����/�Œᖇ�����L��
			if($gold2 > $toper_gold){ $toper_gold = $gold2; }
			if($gold2 <= $under_gold || !$under_gold){ $under_gold = $gold2; }

		}

		# ���C���f�b�N�X�\���p�̏���
		elsif($type =~ /INDEX/){

			# �q�b�g�J�E���^
			$hit_index++;

			# �����̌��ݏ��ʂ��擾
			if($account2 eq $main::pmfile && $account2){ $your_rank = $i; $yourrank_flag = 1; }

			# �y�[�W�߂���
			if($hit_index < ($nowpage_number - 1)*$maxview_index){ next; }
			if($hit_index >= $maxview_index + $maxview_index * ($nowpage_number - 1)){ next; }

			# �\���s�̐��`
			if($account2){ $handle2 = qq(<a href="${main::auth_url}$account2/">$handle2 - $account2</a>); }
			else{ $view_encid2 = qq(<i>��$encid2</i>); }
			if($yourrank_flag){ $yourrank_class = qq( class="your_rank"); }

			# �C���f�b�N�X�̕\���s��ǉ�
			if($type =~ /MOBILE/){ $index_line .= qq(<li>$i�� - $handle2$view_encid2 - $gold2��</li>); }
			else{ $index_line .= qq(<tr><td$yourrank_class>$i��</td><td>$handle2$view_encid2</td><td>$gold2��</td></tr>\n); }

		}
	}

	# ���[�v�𔲂�����̃t�@�C���X�V����
	if($type =~ /RENEW/){

		# �C���f�b�N�X�o�^���Ȃ���΁A�V�����ǉ�
		if(!$still_flag){ unshift(@renewline,"1<>$pgold<>$paccount<>$phandle<>$pencid<>$pkaccesses<>\n"); }

		# ���݂𖇐����Ƀ\�[�g ( 1A )
		if($type =~ /RENEW/){ @renewline = sort { (split(/<>/,$b))[1] <=> (split(/<>/,$a))[1] } @renewline; }
		
		# �g�b�v�f�[�^��ǉ� ( 1B )
		if($tkey eq ""){ $tkey = 1; }
		unshift(@renewline,"$tkey<>$main::time<>$i<>$toper_gold<>$under_gold<>\n");

		# �t�@�C�����X�V
		seek($FILE1,0,0);
		truncate($FILE1,tell($FILE1));
		print $FILE1 @renewline;
	}

# �t�@�C�������
close($FILE1);

	if($type =~ /RENEW/){ Mebius::Chmod(undef,$file1); }

	# ���C���f�b�N�X�𐮌`
	if($type =~ /INDEX/){

		# �g�є�
		if($type =~ /MOBILE/){
		$index_line = qq(<ul>$index_line</ul>);
		}

		# �o�b��
		else{
			$index_line = qq(<table summary="�V�����X�̃��X�g" class="newlist"><tr><th class="rank">����</th><th class="sub">�M��</th><th class="bbs">����</th></tr>\n$index_line\n</table>);
		}

	}

	# �����Ȃ��̃����L���O
	if($type =~ /INDEX/){
		if($type =~ /GOLD/){ $guide1 .= qq(�f���ɏ������ނƁA�������ɉ����ċ��݂������܂��B�A�J�E���g�Ƀ��O�C������A�ꕔ�̌g�ѓd�b�ł̓����L���O�ɓo�^����܂��B); }
		elsif($type =~ /SILVER/){ $guide1 = qq(��݂́A���Ȃ��������ɉ҂��������ł��B�A�J�E���g�Ƀ��O�C������A�ꕔ�̌g�ѓd�b�ł̓����L���O�ɓo�^����܂��B); }
		if($your_rank){ $guide1 .= qq(���Ȃ��̃����L���O�� <strong class="red">$your_rank��</strong> �ł��B); }
	}

# ���^�[��
return($index_line,$guide1,$max_pagelinks);

}



#-----------------------------------------------------------
# �V���^�O
#-----------------------------------------------------------
sub tag{

# �Ǐ���
my($type,$searchword,$maxview_line,$postdata) = @_;
my($ptagname,$penctagname,$ptagnum) = split(/<>/,$postdata);
my($file,$filehandle1,$tagline,$i,$link1,$hit);
my($line,$guide1,$form_name,@renewline,$filehandle1);

	# ���^�[��
	if($main::secret_mode){ return; }

	# �������[�h�ŃL�[���[�h�������ꍇ
	#if($type =~ /SEARCH/ && $searchword eq ""){ return(); }

	# �ő�\���s����ݒ�
	if(!$maxview_line){
		if($type =~ /MOBILE/){ $maxview_line = 30; }
		else{ $maxview_line = 300; }
	}

# �t�@�C����`
$file = "${main::int_dir}_sinnchaku/alltag.log";

# CSS���`
$main::css_text .= qq(
div.newtag{margin:1em 0em 0em 0em;font-size:100%;word-spacing:0.4em;line-height:1.8em;}
.notice1{}
.notice2{font-size:125%;font-weight:bold;}
.notice3{font-size:140%;font-weight:bold;}
.notice4{font-size:170%;font-weight:bold;}
.notice5{font-size:210%;font-weight:bold;}
.notice6{font-size:210%;font-weight:bold;color:#080;}
.notice7{font-size:210%;font-weight:bold;color:#f55;}
);


	#�t�@�C�����Ȃ���΍��
	if($type =~ /RENEW/ && !-e $file){ Mebius::Fileout("NEWMAKE",$file); }

	# �V�����ǉ�����s
	if($type =~ /RENEW/ && $type =~ /NEWLIST/){ push(@renewline,"$ptagnum<>$ptagname<>$penctagname<>\n"); }

# �}�C�^�O�t�@�C�����J��
open($filehandle1,"+<$file");

	# �t�@�C�����b�N
	if($type =~ /RENEW/){ flock($filehandle1,2); }

	# �t�@�C����W�J
	while(<$filehandle1>){

		# �s�𕪉�
		chomp;
		my($tagnum2,$tagname2,$enctagname2) = split(/<>/);

		# �Ǐ���
		my($class);
		$i++;

			# �� �t�@�C�����X�V����ꍇ
			if($type =~ /RENEW/){
				if($i >= 5000){ last; }											# �o�^�ő�s���ɒB�����ꍇ
				if($type =~ /NEWLIST/ && $tagname2 eq $ptagname){ next; }		# �o�^�^�O�Ƃ��̍s�̃^�O���������̂̏ꍇ
				else{ push(@renewline,"$tagnum2<>$tagname2<>$enctagname2<>\n"); }
			}

			# ���C���f�b�N�X�s���擾
			if($type =~ /INDEX/){

				# �ő�\���s��
				if($maxview_line && $hit >= $maxview_line){ last; }

				# ���[�h����
				if($type =~ /SEARCH/){
					if($searchword eq ""){ last; }
					if(index($tagname2,$searchword) >= 0){ } else { next; }
				}

				# �o�^���ɉ����ă^�O������傫������
				if($type =~ /INDEX/ && $type !~ /MOBILE/){
					if($tagnum2 < 5){ }
					elsif($tagnum2 < 25){ $class = qq( class="notice2"); }
					elsif($tagnum2 < 50){ $class = qq( class="notice3"); }
					elsif($tagnum2 < 100){ $class = qq( class="notice4"); }
					elsif($tagnum2 < 250){ $class = qq( class="notice5"); }
					elsif($tagnum2 < 500){ $class = qq( class="notice6"); }
					else{ $class = qq( class="notice7"); }
				}

				# �q�b�g�J�E���^
				$hit++;

				# �s�𐮌`
				if($type =~ /INDEX/){
					if($main::admin_mode){ $line .= qq(<a href="${main::main_url}?mode=tag-$main::submode2-v-$enctagname2"$class>$tagname2</a>\n); }
					else{ $line .= qq(<a href="tag-$main::submode2-v-$enctagname2.html"$class>$tagname2</a>\n); }
				}

			}

	}

	# �t�@�C�����X�V
	if($type =~ /RENEW/){
		seek($filehandle1,0,0);
		truncate($filehandle1,tell($filehandle1));
		print $filehandle1 @renewline;
	}

# �t�@�C�������
close($filehandle1);

	# �p�[�~�b�V�����ύX
	if($type =~ /RENEW/){ Mebius::Chmod(undef,$file); }

	# �C���f�b�N�X�𐮌`
	if($type =~ /INDEX/){
		if($line){ $line = qq(<div class="newtag">$line</div>); }
		else{ 	$line = qq(<div class="newtag not_hit">�q�b�g���܂���ł����B</div>); $hit = 0; }
	}

	# �����{�b�N�X�Ƀt�H�[�J�X�𓖂Ă�
	if($type =~ /INDEX/){ $main::body_javascript = qq( onload="document.TAGSEARCH.word.focus()"); }

# ���^�[��
return($line,$guide1,$hit);

}

#-----------------------------------------------------------
# �S�Ă̋L�� (�܂��͑S�Ẵ��X)���擾 / �X�V
#-----------------------------------------------------------
sub threadres{

# �錾
my($type,$searchword,$maxview_line,$nowpage,$postdata,$sc2,@buffer_line) = @_;
my(undef,$duplication_comment) = @_;
my($my_use_device) = Mebius::my_use_device();
my($none,@unlinks) = @_ if($type =~ /UNLINK/);
my($prealmoto,$ptitle,$ppostnumber,$presnumber,$psubject,$phandle,$pcomment,$pcategory,$paccount,$pencid,$palert_type) = split(/<>/,$postdata);
my($i,$i_index,$i_index_foreach,$i_index_pagelinks,$pagelinks,$i_oneline,$i_comment2,$hit_roop_comment2,$hit_oneline,$one_line,$filehandle1,$top1,$hit_index,$hit_index_foreach,$hit_oneline,$index_line,$logfile,@renewline,@over_buffer_line,$newkey);
my($maxline_renew,$maxline_renew_buffer,$buffer_over_flag,$search_form,$comment2_hitword,@index_line,$unlinks,$duplication_flag,$i_duplication,$duplication_thread);

	# �t�@�C���X�V���̉����`�F�b�N ( �o�b�t�@�t�@�C���̈��p�� )
	if($type =~ /Over/){
		if(@buffer_line <= 0){ return(); }
	}

	# �t�@�C���X�V���̉����`�F�b�N ( ���ʂ̓��e�f�[�^ )
	elsif($type =~ /RENEW/){
		$ppostnumber =~ s/\D//g;
		$presnumber =~ s/\D//g;
		$prealmoto =~ s/\W//g;
			if($ppostnumber eq ""){ return(); }
			if($prealmoto eq ""){ return(); }
			if($presnumber eq "" && $type =~ /RES/){ return(); }
	}

	# �t�@�C���폜���̃`�F�b�N
	if($type =~ /UNLINK/){
		if(@unlinks <= 0){ return(); }
	}

	# ���^�[��
	if($main::secret_mode){ return; }
	if(!$main::alocal_mode && ($prealmoto eq "test" || $prealmoto eq "test2")){ return; }

	# �������[�h�ŃL�[���[�h�������ꍇ
	#if($type =~ /SEARCH/ && $searchword eq ""){ return(); }

	# ��������i�荞�ݑΏۂ��`
	if($sc2 =~ /subject/){ $type .= " SUBJECT"; }
	if($sc2 =~ /handle/){ $type .= " HANDLE"; }
	if($sc2 =~ /account/){ $type .= " ACCOUNT"; }
	if($sc2 =~ /date/){ $type .= " DATE"; }
	if($sc2 =~ /comment/){ $type .= " COMMENT"; }
	if($sc2 =~ /id/){ $type .= " ID"; }
	if($sc2 =~ /title/){ $type .= " TITLE"; }

	# �������[�h�ŁA�i���ݎw�肪�Ȃ��̏ꍇ�A�S�Ώۂ��猟������悤��
	if($type =~ /SEARCH/ && $type !~ /(SUBJECT|HANDLE|ACCOUNT|DATE|COMMENT|ID|TITLE)/){ $type .= qq( SUBJECT HANDLE ACCOUNT DATE COMMENT ID TITLE); }	

	# �ݒ� - �C���f�b�N�X�̍ő�\���s�� ( ���p���l���Ȃ��ꍇ )
	if($type =~ /INDEX/ && !$maxview_line){
			if($type =~ /MOBILE/){ $maxview_line = 20; }
			else{ $maxview_line = 50; }
	}

	# �ݒ� - ���݂̃y�[�W�� ( ���p���l���Ȃ��ꍇ )
	if(!$nowpage){ $nowpage = 1; }

	# �ݒ� - ���O�t�@�C���ɋL�^����ő�s��
	if($type =~ /THREAD/){
		$maxline_renew = 5000;
	}
	elsif($type =~ /RES/){
		if($type =~ /Buffer/){
			$maxline_renew_buffer = 100;	# ���̍s�������܂�����A�{�t�@�C���Ƀf�[�^�������p��
			$maxline_renew = 500;			# �o�b�t�@�t�@�C���Ƃ��ċL�^����ő�s��
		}
		else{ $maxline_renew = 5000; }
	}
	elsif($type =~ /From-other-site-file/){
		$maxline_renew = 500;
	}
	elsif($type =~ /ECHECK/){
		$maxline_renew = 500;
	}

	# CSS��`�i���[�h�����j
	if($type =~ /SEARCH/ && $searchword){
		$main::css_text .= qq(strong.hit{});
	}

	# CSS��`�i�C���f�b�N�X�\���j
	if($type =~ /INDEX/){
		$main::css_text .= qq(
		div.comment2{padding:0.25em 0.5em;margin:0.35em 1em;font-size:95%;line-height:1.4em;background:#dee;}
		div.search_url{padding:0em 0em 1em 0em;}
		a.search_url{color:#080;}
		a.search_plus{font-size:90%;}
		table{font-size:100%;}
		div.not_hit{font-style:italic;color#333;font-size:95%;}
		);
	}

	# �t�@�C���X�V���A�L�[���\���ɂ���ꍇ
	if($type =~ /RENEW/){
			if($type =~ /Hidden-from-top/){ $newkey .= qq( Hidden-from-top); }
			elsif($main::in{'sex'} || $main::in{'vio'}){ $newkey .= qq( Hidden-from-top); }
			elsif($psubject =~ m!//!){ $newkey .= qq( Hidden-from-top); }
			elsif($psubject =~ /(��|�\\|�O��|BL|GL|�a�k|�f�k)/){ $newkey .= qq( Hidden-from-top); }
			elsif($main::bbs{'concept'} =~ /Sousaku-mode/ && $psubject =~ /(�C�W��|������|�s��|�Ղ�|�c��|����)/){ $newkey .= qq( Hidden-from-top); }
			elsif($main::concept =~ /NOT-NEWS/){ $newkey .= qq( Hidden-from-top); }
			else{ $newkey = 1; }
	}

	# �t�@�C����`
	if($type =~ /THREAD/){
		$logfile = "${main::int_dir}_sinnchaku/allthread.log";
	}
	elsif($type =~ /RES/){
		if($type =~ /Buffer/){ $logfile = "${main::int_dir}_sinnchaku/allres_buffer.log"; } # �o�b�t�@�t�@�C��
		else{ $logfile = "${main::int_dir}_sinnchaku/allres.log"; }							# �{�t�@�C��
	}
	elsif($type =~ /ECHECK/){
		$logfile = "${main::int_dir}_sinnchaku/echeck.log";
	}
	elsif($type =~ /From-other-site-file/){
		$logfile = "${main::int_dir}_sinnchaku/from_othersite_bbs_res.log";
	}
	else{ return; }

	# �t�@�C�����Ȃ���΍쐬
	if(!-e $logfile){ Mebius::Fileout("NEWMAKE",$logfile); }

# �t�@�C�����J��
open($filehandle1,"+<$logfile");

	# �t�@�C�����b�N
	if($type =~ /(RENEW|UNLINK)/){ flock($filehandle1,2); }

# �g�b�v�f�[�^���擾�A����
$top1 = <$filehandle1>; chomp $top1;

# �g�b�v�f�[�^��ǉ�
my($tkey,$tlasttime,$tcount,$tdate) = split(/<>/,$top1);

	# �o�b�t�@�t�@�C�������̏ꍇ�A���C���t�@�C���X�V�̃t���O�𗧂Ă� 
	if($type =~ /RENEW/ && $type =~ /Buffer/){
			if($tcount && $tcount % $maxline_renew_buffer == 0){ $buffer_over_flag = 1; }
	}

	# �g�b�v�f�[�^��ǉ�
	if($type =~ /(RENEW|UNLINK)/){
		if($tkey eq ""){ $tkey = 1; }
	$tcount++;
	push(@renewline,"$tkey<>$main::time<>$tcount<>$main::date<>\n");
	}

	# �V�����ǉ�����s
	if($type =~ /RENEW/){

		# �o�b�t�@�t�@�C��������p��������ꍇ
		if($type =~ /Over/ && @buffer_line){
			push(@renewline,@buffer_line);
		}

		# ���e�f�[�^����P�s�ǉ��̏ꍇ
		else{
	push(@renewline,"$newkey<>$prealmoto<>$ptitle<>$ppostnumber<>$psubject<>$phandle<>$pcomment<>$presnumber<>$main::time<>$main::date<>$pcategory<>$paccount<>$pencid<>$palert_type<>\n");
		}

	}

	# ���t�@�C����W�J
	while(<$filehandle1>){

		my(%data);

	# �����J�E���^
	$i++;

	# ���̍s�𕪉�
	chomp;
	my($key2,$realmoto2,$title2,$postnumber2,$subject2,$handle2,$comment2,$resnumber2,$time2,$date2,$category2,$account2,$encid2,$alert_type2) = split(/<>/);
	($data{'key'},$data{'bbs_kind'},$data{'title'},$data{'thread_number'},$data{'subject'},$data{'last_handle'},$data{'comment'},$data{'res_number'},$data{'last_regist_time'},$data{'date'},$data{'category'},$data{'account'},$data{'id'},$data{'alert_type'}) = split(/<>/);

		# ���{�����d���`�F�b�N������ꍇ
		if($type =~ /Duplication-check/){
			$i_duplication++;
			#if($i_duplication >= 200){ last; }	# ���ȏ�̍s���ɂȂ�����A����I��
			if($main::time >= $time2 + 30*60){ last; }	# ��莞�Ԉȏ�O�̃��X�ɂȂ�����A����I��
			#if($duplication_flag){ next; }

			my($flag) = Mebius::Text::Duplication("",$duplication_comment,$comment2);
			if($flag){
				$duplication_flag = $flag;
				$duplication_thread = qq(<a href="/_$realmoto2/$postnumber2.html#S$resnumber2">$subject2</a>);
			}
		}

		# ���t�@�C���X�V�̏ꍇ�A�e�s��ǉ�
		if($type =~ /(RENEW|UNLINK)/){

			# �ő�h�擾�h�s�����������I�����ꍇ
			if($i >= $maxline_renew){ last; }

			# �s���폜����ꍇ
			if($type =~ /UNLINK/ && $key2 !~ /Deleted/){
					foreach $unlinks (@unlinks){
						if($unlinks eq ""){ next; }
						# �P�L���ɑ�����A�S�Ẵ��X���폜����ꍇ
						if($type =~ /RES/ && $type =~ /UNLINK-ALL/ && "$realmoto2-$postnumber2" eq $unlinks){ $key2 .= qq( Deleted); }
						# ���ʂɃ��X��L�����폜
						if("$realmoto2-$postnumber2-$resnumber2" eq $unlinks){ $key2 .= qq( Deleted); }
					}
			}
			
		# ���̍s��ǉ�
		push(@renewline,"$key2<>$realmoto2<>$title2<>$postnumber2<>$subject2<>$handle2<>$comment2<>$resnumber2<>$time2<>$date2<>$category2<>$account2<>$encid2<>$alert_type2<>\n");

				# �o�b�t�@�t�@�C��������p���s��ǉ�
				if($type =~ /Buffer/ && $buffer_over_flag && $i <= $maxline_renew_buffer){
		push(@over_buffer_line,"$key2<>$realmoto2<>$title2<>$postnumber2<>$subject2<>$handle2<>$comment2<>$resnumber2<>$time2<>$date2<>$category2<>$account2<>$encid2<>$alert_type2<>\n");
				}

		}

		# ���P�s�\�����擾
		if($type =~ /ONELINE/){
				$i_oneline++;
				if($hit_oneline >= $maxview_line){ last; }		# �ő�"�\��"�s�����q�b�g���I�����Ƃ�
				if($type =~ /Fillter/ && $key2 =~ /Hidden-from-top/){ next; }	# �g�b�v�y�[�W�ȂǂŃt�B���^��������(���I/�V���b�L���O�ȋL�����G�X�P�[�v)
				if($key2 =~ /Deleted/){ next; }
				if($hit_oneline >= 1){ $one_line .= qq( �b ); }
			$one_line .= qq(<a href="/_$realmoto2/$postnumber2.html" class="oneline$i_oneline">$subject2</a>);
			$one_line .= qq( ( <a href="/_$realmoto2/$postnumber2.html#S$resnumber2">$handle2</a> ) );
			$one_line .= qq( - <a href="/_$realmoto2/" class="green">$title2</a> );
			$hit_oneline++;
		}

	# �C���f�b�N�X�p�̋Ǐ���
	my($hitpoint,$comment2_split,$comment2_length,$comment2_length_search,$view_comment2);

		# ���C���f�b�N�X�̕\���z����擾
		if($type =~ /INDEX/){

				# ���ʂ̏I������
				if($key2 =~ /Deleted/){ next; }

				# �����s�����J�E���g
				$i_index++;

					# �L�[���[�h����������ꍇ ( �����s������ )
					if($type =~ /SEARCH/){

						# �I�������A���񏈗�
						if($searchword eq ""){ last; }	# �����ꂪ�Ȃ��ꍇ�A���[�v���I��

						# �Ǐ���
						my($keyword,$hitflag,$keyword_num,$searchword_buf);
						my($subject2_hit,$handle2_hit,$account2_hit,$encid2_hit,$date2_hit,$comment2_hit,$other_comment2_hit);
						my($title2_hit);

						# �S�p�X�y�[�X�Ȃǂ𔼊p�X�y�[�X�ɕϊ�
						$searchword_buf = $searchword;
						$searchword_buf =~ s/(�@|\s)/ /g;

						# ���p�X�y�[�X��؂�ŃL�[���[�h��W�J
						foreach $keyword (split(/ /,$searchword_buf)){

							if($searchword eq ""){ last; }		# �����ꂪ�Ȃ��ꍇ
							if($keyword eq ""){ next; }			# ���̃��[�v�̃L�[���[�h�������ꍇ
							$keyword_num++;						# �L�[���[�h�����v�Z�A���Z

							# �薼���q�b�g
							if($type =~ /SUBJECT/ && index($subject2,$keyword) >= 0){
								$subject2_hit++;
								$hitflag++;
								$hitpoint += 2;
							}

							# �M�����q�b�g
							if($type =~ /HANDLE/ && index($handle2,$keyword) >= 0){
								$handle2_hit++;
								$hitflag++;
								$hitpoint += 1;
							}

							# �A�J�E���g�����q�b�g
							if($type =~ /ACCOUNT/ && index($account2,$keyword) >= 0){
								$account2_hit++;
								$hitflag++;
								$hitpoint += 3;
							}

							# �h�c���q�b�g
							if($type =~ /ID/ && length($searchword) >= 4){
									if(index($encid2,$keyword) >= 0 || index("��$encid2",$keyword) >= 0){
										$encid2_hit++;
										$hitflag++;
										$hitpoint += 3;
									}
							}

							# �f�������q�b�g
							if($type =~ /TITLE/ && length($searchword) >= 4 && index($title2,$keyword) >= 0){
								$title2_hit++;
								$hitflag++;
								$hitpoint += 0.5;
							}

							# ���t���q�b�g
							if($type =~ /DATE/ && length($searchword) >= 4 && index($date2,$keyword) >= 0){
								$date2_hit++;
								$hitflag++;
								$hitpoint += 5;
							}

							# �{�����q�b�g
							if($type =~ /COMMENT/){

								# �{����W�J
								foreach $comment2_split (split(/(<br>| |�@|�A|�B)/,$comment2)){

									# �s���J���̏ꍇ�͏������Ȃ�
									if($comment2_split =~ /^(<br>| |�@|�A|�B|)$/){ next; }

									# �\�������������߂����ꍇ
									if($comment2_length_search >= 200){ last; }

								# ���[�v�J�E���^
								$i_comment2++;
									
									# �q�b�g�����s�̏ꍇ
									if(index($comment2_split,$keyword) >= 0){
										$comment2_hit++;
										$hitflag++;
										$hit_roop_comment2 = $i_comment2;
										$comment2_length_search += length($comment2_split);
										$view_comment2 .= qq( <strong class="hit">$comment2_split</strong>);
									}

									# �q�b�g���Ȃ������s�̏ꍇ
									else{
											if(!$comment2_hit && !$view_comment2){
												$comment2_length_search += length($comment2_split);
												$view_comment2 = $comment2_split;
											}
											elsif($i_comment2 <= $hit_roop_comment2 + 2){
												$comment2_length_search += length($comment2_split);
												$view_comment2 .= qq( $comment2_split);
											}
									}
								}

						# �ŏI�\���𐮌`
						$view_comment2 =~ s/(<br>)/ /g;
					}
				}

				# �����I����̏��� 

				#( �q�b�g�� $hitflag ���A���p�X�y�[�X�ŋ�؂����L�[���[�h�́h���h�ȏ�ł���΃q�b�g�Ƃ���j
				if($hitflag >= $keyword_num){

						# �q�b�g�����L�[���[�h�̋���
						if($subject2_hit){ $subject2 = qq(<strong class="hit">$subject2</strong>); }
						if($handle2_hit){ $handle2 = qq(<strong class="hit">$handle2</strong>); }
						if($account2_hit){ $account2 = qq( - <strong><a href="${main::auth_url}$account2/" class="hit">$account2</a></strong>); } else { $account2 = ""; }
						if(!$encid2_hit){ $encid2 = ""; }
						if($date2_hit){ $date2 = qq(<strong class="hit">$date2</strong>); }
						if($title2_hit){ $title2 = qq(<strong class="hit">$title2</strong>); }
					
					# �q�b�g�|�C���g���v�Z
					$hitpoint += $hitflag;
					$hitpoint += int(($maxline_renew - $i) / 100);		# ���t�̑����Ń|�C���g��ǉ�
				}

				# �q�b�g���Ȃ������ꍇ�A���񏈗���
				else{ next; }
			}

			# �L�[���[�h�����������A���ʂɕ\������ꍇ
			else{

				# ����/�I������
				if($hit_index >= $maxview_line){ last; }		# �ő�"�\��"�s�����q�b�g���I�����Ƃ�
				if($i_index >= 1000){ last; }					# �ő�"�擾"�s�����������I�����Ƃ�
				if($nowpage =~ /^\d$/ && $i_index > ($nowpage * $maxview_line)){ last; }	# �y�[�W�߂���P
				if($nowpage =~ /^\d$/ && $i_index <= ($nowpage-1) * $maxview_line){ next; }	# �y�[�W�߂���Q
				if($nowpage =~ /[a-z]/ && $nowpage ne $category2){ next; }					# �J�e�S���i��

			}

			# �������Ȃ������ꍇ��A�������Ă��{�����q�b�g���Ȃ������ꍇ�A�{����W�J
			if(!$view_comment2){
				foreach $comment2_split (split(/(<br>| |�@|�A|�B)/,$comment2)){
				$comment2_split =~ s/(�@|<br>)//g;
				$comment2_length += (length($comment2_split) ) / 2;
				$view_comment2 .= qq( $comment2_split);
					if($comment2_length >= 100){ last; }
				}
			}

			# �q�b�g�J�E���^
			$hit_index++;

			# �C���f�b�N�X�z���ǉ�
			push @index_line , { data_line => "$hitpoint<>$key2<>$realmoto2<>$title2<>$postnumber2<>$subject2<>$handle2<>$view_comment2<>$resnumber2<>$time2<>$date2<>$category2<>$account2<>$encid2<>$alert_type2<>\n" , data_ref => \%data };

		}

	}

	# �t�@�C�����X�V
	if($type =~ /(RENEW|UNLINK)/){
		seek($filehandle1,0,0);
		truncate($filehandle1,tell($filehandle1));
		print $filehandle1 @renewline;
	}

# �t�@�C�������
close($filehandle1);

	# ���d�����e�`�F�b�N�̏ꍇ�̃��^�[��
	if($type =~ /Duplication-check/){
		return($duplication_flag,$duplication_thread);
	}

	# �����O�t�@�C���̃p�[�~�b�V������ύX
	if($type =~ /(RENEW|UNLINK)/){ Mebius::Chmod(undef,$logfile); }

	# ���P�s�\���𐮌`���ă��^�[��
	if($type =~ /ONELINE/){
		return($one_line);
	}

	# ���C���f�b�N�X���\�[�g
	if($type =~ /INDEX/ && $type =~ /SEARCH/){
		@index_line = sort { (split(/<>/,$b))[0] <=> (split(/<>/,$a))[0] } @index_line;
	}

	# ���擾�����C���f�b�N�X���ēW�J
	if($type =~ /INDEX/){

		# �z���W�J
		foreach(@index_line){

		# ���[�v�J�E���^
		$i_index_foreach++;

		# �P�s�𕪉�
		chomp;
		my($hitpoint,$key2,$realmoto2,$title2,$postnumber2,$subject2,$handle2,$comment2,$resnumber2,$time2,$date2,$category2,$account2,$encid2,$alert_type2) = split(/<>/,$_->{'data_line'});
		my($view_comment2);

			# �ő�"�\��"�s�����q�b�g���I�����Ƃ�
			if($hit_index_foreach >= $maxview_line){ last; }

			# �L�[���[�h���������ꍇ�̎��񏈗� ( �q�b�g���𓾂āA���ёւ�������ł̏��� )
			if($type =~ /SEARCH/){
				if($nowpage =~ /^([\d]+)$/ && $i_index_foreach > ($nowpage * $maxview_line)){ next; }	# �y�[�W�߂���P
				if($nowpage =~ /^([\d]+)$/ && $i_index_foreach <= ($nowpage-1) * $maxview_line){ next; }# �y�[�W�߂���Q				#if($nowpage =~ /[a-z]/ && $nowpage ne $category2){ next; }							# �J�e�S���i��
			}


			# �P�s�̕\�����e������i���o�C���Łj
			if($type =~ /MOBILE/){
				$index_line .= qq(<li>);
				$index_line .= qq(<a href="/_$realmoto2/$postnumber2.html">$subject2</a>);
				$index_line .= qq(( <a href="/_$realmoto2/$postnumber2.html#S$resnumber2">$handle2</a> ));
				$index_line .= qq(</li>);
				
			} elsif($my_use_device->{'smart_phone_flag'}){

				my ($smart_phone_line) = shift_jis(Mebius::BBS::Index::view_thread_menu_core_for_smart_phone($_->{'data_ref'},{ SJIS => 1 , hit_round => $hit_index_foreach }));
				$index_line .= $smart_phone_line;
				
			# �P�s�̕\�����e������i�f�X�N�g�b�v�Łj
			 } else{

				my($view_hitpoint) = qq($hitpoint / $i_index_foreach \) ) if($type =~ /SEARCH/ && $main::myadmin_flag >= 5);

				# ���`
				$index_line .= qq(<tr>);

				# �L����
				$index_line .= qq(<td>);
				$index_line .= qq($view_hitpoint<a href="/_$realmoto2/$postnumber2.html">$subject2</a>);
					if($alert_type2){ $index_line .= qq( <span class="alert">[ $alert_type2�H ] </span>); }
				$index_line .= qq(</td>);

					# �M��
					if($encid2 && $type =~ /SEARCH/){ $encid2 = qq(<i>��$encid2</i>); } else { $encid2 = ""; }
					if($account2 && $type =~ /SEARCH/){ } else { $account2 = ""; }

					if($type =~ /Admin-view/){
						$index_line .= qq(<td>( <a href="${main::jak_url}$realmoto2.cgi?mode=view&amp;no=$postnumber2#S$resnumber2">$handle2</a>$account2$encid2 )</td>);
					}
					else{
						$index_line .= qq(<td>( <a href="/_$realmoto2/$postnumber2.html#S$resnumber2">$handle2</a>$account2$encid2 )</td>);
					}

				# �f����
				$index_line .= qq(<td>( <a href="/_$realmoto2/" class="green">$title2</a> )</td>);
				$index_line .= qq(<td>$date2</td>);
				$index_line .= qq(</tr>\n);

				# �{��
				$index_line .= qq(<tr><td colspan="4"><div class="comment2">$comment2</div></td></tr>\n);


			}

			$hit_index_foreach++;

		}

	}

	# ���o�b�t�@�t�@�C�����K��s���ɒB�����ꍇ�A�{�̃t�@�C�����X�V ( �������[�v�ɒ��ӁI )
	if($type =~ /Buffer/ && $buffer_over_flag){
			if($type =~ /RES/){
				Mebius::Newlist::threadres("RENEW RES Over","","","","","",@over_buffer_line);
			}
	}

	# ���C���f�b�N�X�s�𐮌`���ă��^�[��
	if($type =~ /INDEX/){

		# �q�b�g�����ꍇ
		if($index_line){

			# �y�[�W�߂��胊���N���쐬
			if($type =~ /SEARCH/){
				my($move);
					if($type =~ /THREAD/){ $move = qq(#THREAD); }
					elsif($type =~ /RES/){ $move = qq(#RES); }

					for(0..($hit_index/$maxview_line)){
						$i_index_pagelinks++;
							if($i_index_pagelinks > 10){ next; }
						my $postbuf_query_esc2 = $main::postbuf_query_esc;
						$postbuf_query_esc2 =~ s/mode=$main::submode1-$main::submode2-([\d]+)/mode=$main::submode1-$main::submode2-$i_index_pagelinks/g;
							if($i_index_pagelinks == $nowpage){ $pagelinks .= qq($i_index_pagelinks\n); }
							else{ $pagelinks .= qq(<a href="${main::script}?$postbuf_query_esc2$move">$i_index_pagelinks</a>\n); }
					}
				$pagelinks = qq(<div class="allsearch_pagelinks">�y�[�W: $pagelinks</div>);
			}
			
			# ���` ( ���o�C���� )
			if($my_use_device->{'smart_flag'}){
				
			}	elsif($type =~ /MOBILE/){
				$index_line = qq(<ul>$index_line</ul>\n);
			}
			# ���` ( �o�b�� )
			else{
				$index_line = qq(
			<table summary="�S�Ă̋L��" class="threadres" class="newlist"><tr><th class="sub">�L��</th><th class="name">���e��</th><th class="bbs">�f����</th><th class="date">����</th></tr>$index_line</table>
			\n
			);
			}

		}

		# �q�b�g���Ȃ������ꍇ
		else{
			$index_line = qq(<div class="not_hit">�q�b�g���܂���ł����B</div>);
			$hit_index = 0;
		}
	
	# ���^�[��
	return($index_line,$hit_index);
	}

	# �����̑��̃��^�[��
	else{ return(1); }

}

#-----------------------------------------------------------
# �S����
#-----------------------------------------------------------
sub allsearch{

# �錾
my($type,$searchword,$sc1,$sc2) = @_;
my($line,$line_tag,$line_allthread,$line_allres,$hit_tag,$hit_allthread,$hit_allres,$none,$plustype);
my($maxview_tag,$maxview_allthread,$maxview_allres,$google_link,$google_link_mobile,$h2_style);


	# �A�N�Z�X�U�蕪�� ( ���o�C���Ł��o�b�� �j
	if($type =~ /MOBILE/){

		my($postbuf_divide) = $ENV{'REQUEST_URI'};
		$postbuf_divide =~ s/mode=allsearch-k-/mode=allsearch-p-/g;
		$main::divide_url = "http://$main::server_domain$postbuf_divide";


			#if($main::device_type eq "desktop"){ main::divide($main::divide_url,"desktop"); }
	}
	# �A�N�Z�X�U�蕪�� ( �o�b�Ł����o�C���� �j
	else{
		my($postbuf_divide) = $ENV{'REQUEST_URI'};
		$postbuf_divide =~ s/mode=allsearch-p-/mode=allsearch-k-/g;
		$main::divide_url = "http://$main::server_domain$postbuf_divide";

			#if($main::device_type eq "mobile"){ main::divide($main::divide_url,"mobile"); }
	}

	# URL���܂Ƃ߂�
	if($main::submode2 eq "k"){
		my($request_url) = Mebius::request_url();
		my $redirect_url = $request_url;
		$redirect_url =~ s/(\?|&)mode=allsearch-k-(\d)/${1}mode=allsearch-p-${2}/g;
		$redirect_url =~ s/allsearch-k-(\d).html$/allsearch-p-$1.html/g;
		Mebius::Redirect(undef,$redirect_url,301);
	}


	# Google���������N���`
	my($enc_searchword) = Mebius::Encode("",$searchword);
	if($type =~ /MOBILE/){
	$google_link_mobile = qq(�@<a href="http://www.google.co.jp/m?ie=Shift_JIS&amp;q=$enc_searchword+site%3Amb2.jp" rel="nofollow">��Google�Ō���</a>);
	}
	else{
	$google_link = qq(�@<a href="http://www.google.co.jp/search?q=$enc_searchword&amp;sitesearch=mb2.jp&amp;ie=Shift_JIS&amp;hl=ja&amp;domains=mb2.jp" rel="nofollow">��Google�Ō���</a>);
	}

# h2 �̕\���X�^�C�����`
if($type =~ /MOBILE/){
$h2_style = qq( style="font-size:small;");
}

# ��������A�擾����C���f�b�N�X�̎�ނ��` ( ���̃T�u���[�`�����ł̏��� )
if($sc1 =~ /tag/){ $type .= " TAG"; }
if($sc1 =~ /thread/){ $type .= " THREAD"; }
if($sc1 =~ /res/){ $type .= " RES"; }

# �������[�h���J���̏ꍇ�A�S���[�h����C���f�b�N�X���擾����悤��
if($type !~ /(TAG|THREAD|RES)/){ $type .= qq(TAG THREAD RES); }

# CSS���`
$main::css_text .= qq(
h2.hit{font-size:100%;padding:0.3em 0.5em;margin-left:0.75em;background:#fdd;border:solid 1px #f99;width:50%;font-weight:normal;}
div.allsearch_self{margin-left:1.5em;}
div.allsearch_pagelinks{margin:1em;font-size:120%;}
);

# �^�C�g����`
if($main::in{'word'}){ $main::sub_title = qq(�h$searchword�h�̌������� | ���r�E�X���� | $main::server_domain); }
else{ $main::sub_title = "���r�E�X���� | $main::server_domain"; }

	# �ő�h�\���h�s���̓n���l��ݒ�i���o�C���Łj
	if($type =~ /MOBILE/){
	$maxview_tag = 10;
	$maxview_allthread = 10;
	$maxview_allres = 10;
	}

	# �ő�h�\���h�s���̓n���l��ݒ�i�o�b�Łj
	else{
	$maxview_tag = 30;
	$maxview_allthread = 15;
	$maxview_allres = 15;
	}

	if($searchword){
		main::error("�S�����͌��ݒ�~���ł��B");
	}

	# �^�O���猟��
	if($type =~ /TAG/ && $searchword){
	($line_tag,$none,$hit_tag) = Mebius::Newlist::tag("SEARCH INDEX$main::ktype",$searchword,$maxview_tag);
	}

	# �^�O�𐮌`
	if($line_tag){
	$line_tag = qq(<h2 class="hit" id="TAG"$h2_style>�h�^�O�h���猟���F ( $hit_tag�� ) $google_link</h2><div class="allsearch_self">$line_tag</div>$google_link_mobile);
	}

	# �S���X���猟��
	if($type =~ /RES/ && $searchword){
	($line_allres,$hit_allres) = Mebius::Newlist::threadres("INDEX RES SEARCH$plustype$main::ktype",$searchword,$maxview_allres,$main::submode3,"",$sc2);
	}

	# �S���X�𐮌`
	if($line_allres){
	$line_allres = qq(<h2 class="hit" id="RES"$h2_style>�h�V�������X�h ���猟���F ( $hit_allres�� ) $google_link</h2><div class="allsearch_self">$line_allres</div>$google_link_mobile);
	}
	

	# �S�L�����猟��
	if($type =~ /THREAD/ && $searchword){
	($line_allthread,$hit_allthread) = Mebius::Newlist::threadres("INDEX THREAD SEARCH$plustype$main::ktype",$searchword,$maxview_allthread,$main::submode3,"",$sc2);
	}

	# �S�L���𐮌`
	if($line_allthread){
	$line_allthread = qq(<h2 class="hit" id="THREAD"$h2_style>�h�V�����L���h ���猟���F ( $hit_allthread�� ) $google_link</h2><div class="allsearch_self">$line_allthread</div>$google_link_mobile);
	}

# �ŏI���`
$line = qq(<div class="allsearch" id="HIT">�S�����͌��ݒ�~���ł��B $line_tag $line_allres $line_allthread</div>);

# �A�N�Z�X���O�����
if($searchword){ main::access_log("ALLSEARCH","�L�[���[�h - $searchword"); }

# ���^�[��
return($line);

}

#-----------------------------------------------------------
# �S�����{�b�N�X
#-----------------------------------------------------------
sub allsearch_form{

# �錾
my($type,$searchword,$sc1,$sc2,$plus_class,$move) = @_;
my($line,$xclose,$search_mode_input,$submit_value);
my($checkbox_search_mode,$checked_tag,$checked_thread,$checked_res);
my($checkbox_limit,$checked_subject,$checked_handle,$checked_account,$checked_date,$checked_comment,$checked_id,$checked_title,$checked_title);
my($action,$accesskey,$accesskey_mark,$input_size,$plus_idname);

# �������URL���`
if($main::admin_mode){ $action = "index.cgi"; }

# MOVE ��
if($move){ $move = "#$move"; }

# �������猟�����[�h���`
if($sc1 =~ /tag/){ $type .= " TAG"; }
if($sc1 =~ /thread/){ $type .= " THREAD"; }
if($sc1 =~ /res/){ $type .= " RES"; }

# �������[�h�̎w�肪�Ȃ��ꍇ�A�S�Ώۂ̃`�F�b�N�{�b�N�X���I����
#if($type !~ /(TAG|THREAD|RES)/){ $type .= qq( TAG THREAD RES); }

# ��������i���ݑΏۂ��`
if($sc2 =~ /subject/){ $type .= " SUBJECT"; }
if($sc2 =~ /handle/){ $type .= " HANDLE"; }
if($sc2 =~ /account/){ $type .= " ACCOUNT"; }
if($sc2 =~ /date/){ $type .= " DATE"; }
if($sc2 =~ /comment/){ $type .= " COMMENT"; }
if($sc2 =~ /id/){ $type .= " ID"; }
if($sc2 =~ /title/){ $type .= " TITLE"; }

# �i���ݎw�肪�Ȃ��ꍇ�A�S�Ώۂ̃`�F�b�N�{�b�N�X���I����
#if($type !~ /(SUBJECT|HANDLE|ACCOUNT|DATE|COMMENT|ID)/){ $type .= qq( SUBJECT HANDLE ACCOUNT DATE COMMENT ID); }

	# CSS��`
	if($type =~ /CSS1/){
		$main::css_text .= qq(
		span.allsearch_mode_select{font-size:90%;background:#ddd;padding:0.4em 0.4em;}
		span.allsearch_limit_select{font-size:90%;background:#fdd;padding:0.4em 0.4em;}
		);
	}

	# �������[�h�U�蕪���p�`�F�b�N�{�b�N�X
	if($type =~ /SELECT-CHECKBOX/){
		if($type =~ /(TAG)/){ $checked_tag = $main::parts{'checked'}; }
		if($type =~ /(THREAD)/){ $checked_thread = $main::parts{'checked'}; }
		if($type =~ /(RES)/){ $checked_res = $main::parts{'checked'}; }
	$checkbox_search_mode .= qq(<input type="checkbox" name="sc" value="res"$checked_res$xclose> ���X\n);
	$checkbox_search_mode .= qq(<input type="checkbox" name="sc" value="thread"$checked_thread$xclose> �L��\n);
	$checkbox_search_mode .= qq(<input type="checkbox" name="sc" value="tag"$checked_tag$xclose> �^�O\n);
	$checkbox_search_mode = qq(<span class="allsearch_mode_select">$checkbox_search_mode</span>);
	}

	# �������[�h�U�蕪������ hidden �l
	elsif($type =~ /SELECT-HIDDEN/){
		if($type =~ /(TAG)/){ $search_mode_input .= qq(<input type="hidden" name="sc" value="tag"$xclose>); }
		if($type =~ /(THREAD)/){ $search_mode_input .= qq(<input type="hidden" name="sc" value="thread"$xclose>); }
		if($type =~ /(RES)/){ $search_mode_input .= qq(<input type="hidden" name="sc" value="res"$xclose>); }
	}

	# �����Ώۂ̍i����
	if($type =~ /LIMIT-CHECKBOX/){
		if($type =~ /(SUBJECT)/){ $checked_subject = $main::parts{'checked'}; }
		if($type =~ /(HANDLE)/){ $checked_handle = $main::parts{'checked'}; }
		if($type =~ /(ACCOUNT)/){ $checked_account = $main::parts{'checked'}; }
		if($type =~ /(ID)/){ $checked_id = $main::parts{'checked'}; }
		if($type =~ /(DATE)/){ $checked_date = $main::parts{'checked'}; }
		if($type =~ /(COMMENT)/){ $checked_comment = $main::parts{'checked'}; }
		if($type =~ /(TITLE)/){ $checked_title = $main::parts{'checked'}; }
	$checkbox_limit = qq(<input type="checkbox" name="sc2" value="subject"$checked_subject$xclose> �薼\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="comment"$checked_comment$xclose> �{��\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="handle"$checked_handle$xclose> �M��\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="id"$checked_id$xclose> �h�c\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="account"$checked_account$xclose> �A�J�E���g��\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="title"$checked_title$xclose> �f����\n);
	$checkbox_limit .= qq(<input type="checkbox" name="sc2" value="date"$checked_date$xclose> ���t\n);
	$checkbox_limit = qq(�@<span class="allsearch_limit_select">$checkbox_limit</span>);
	}

	# �g�єŃt�b�^�̏ꍇ�̐��`
	if($type =~ /MOBILE/){
		#$accesskey = qq( accesskey="0");
		#$accesskey_mark = qq(\(0\));
		$input_size = qq( size="8");
		$checkbox_limit = "";
	}

	# ���M�{�^��
	if($type =~ /MOBILE/){ $submit_value = "�S����"; }
	else{ $submit_value = "���r�E�X�S����"; }

# �������N���X�^�O�𐮌`
if($plus_class){
$plus_idname = qq(_$plus_class);
$plus_class = "_" . lc ($plus_class);
}

# �����{�b�N�X�𐮌`
#$line = qq(
#<form action="http://mb2.jp/_main/$move" id="ALLSEARCH$plus_idname" name="ALLSEARCH$plus_idname" class="allsearch_form$plus_class">
#<div class="allsearch_div$plus_class">
#$accesskey_mark<input type="$main::parts{'input_type_search'}" name="word" value="$searchword" class="allsearch_input$plus_class" placeholder="�����L�[���[�h"$input_size$accesskey$xclose>
#<input type="submit" value="$submit_value" class="allsearch_submit$plus_class"$xclose>
#$checkbox_search_mode
#$checkbox_limit
#$search_mode_input
#<input type="hidden" name="mode" value="allsearch-p-1"$xclose>
#</div>
#</form>
#);


# ���^�[��
return($line);

}

use strict;

#-----------------------------------------------------------
# �ő僌�X���ɒB�����X���b�h
#-----------------------------------------------------------
sub Maxres{

# �錾
my($type,%thread) = @_;
my(undef,undef,undef,$select_page) = @_;
my($category_handler,$category_logfile,@renewline_category,$duplication_flag);
my($index_line,$i);

# �y�[�W������̍ő�\���s��
my $maxview_per_page = 100;

# �t�@�C����`
$category_logfile = "${main::int_dir}_maxres/${main::category}_maxres_category.log";
$category_logfile = "${main::int_dir}_sinnchaku/maxres.log";

# �t�@�C�����J��
open($category_handler,"<$category_logfile");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($category_handler,1); }

	# �g�b�v�f�[�^�𕪉�
	chomp(my $top1 = <$category_handler>);
	my($tkey) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$category_handler>){

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪉�
		chomp;
		my($key2,$category2,$realmoto2,$postnumber2,$res2,$subject2,$title2,$handle2,$time2,$date2) = split(/<>/);

			# ���C���f�b�N�X�擾�p
			if($type =~ /Get-index/){

					# �y�[�W�߂���Ŏ��̏�����
					if($i > $maxview_per_page * $select_page){ next; }
					if($i <= $maxview_per_page * ($select_page-1)){ next; }

				# �\������s���`
				$index_line .= qq(<tr>);
				$index_line .= qq(<td><a href="/_$realmoto2/$postnumber2.html">$subject2</a></td>);
				$index_line .= qq(<td><a href="/_$realmoto2/">$title2</a></td>);
				$index_line .= qq(<td>$handle2</td>);
				$index_line .= qq(</tr>\n);
			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){
					# �����L���̏ꍇ
					if($realmoto2 eq $main::realmoto && $postnumber2 eq $thread{'postnumber'}){ next; }
				# ���̍s��ǉ�
				push(@renewline_category,"$key2<>$category2<>$realmoto2<>$postnumber2<>$res2<>$subject2<>$title2<>$handle2<>$time2<>$date2<>\n");
			}


	}

close($category_handler);

	# ���t�@�C�����X�V
	if($type =~ /Renew/){

			# �V�����ǉ�����s
			if(!$duplication_flag){
unshift(@renewline_category,"1<>$main::category<>$main::realmoto<>$thread{'postnumber'}<>$thread{'res'}<>$thread{'subject'}<>$main::head_title<>$thread{'posthandle'}<>$main::time<>$main::date<>\n");
			}

		# �g�b�v�f�[�^��ǉ�
		if($tkey eq ""){ $tkey = 1; }
		unshift(@renewline_category,"$tkey<>\n");

		# �t�@�C���X�V
		Mebius::Fileout("",$category_logfile,@renewline_category);
	}

	# ���C���f�b�N�X�����^�[��
	if($type =~ /Get-index/){

			if($index_line){
				$index_line = qq(<table summary="�L���̈ꗗ" class="newlist">$index_line</table>);
			}

		return($index_line);
	}


}

#-----------------------------------------------------------
# ���G�����ꗗ
#-----------------------------------------------------------
sub Paint{

# �錾
use Mebius::Paint;

# �錾
my($type) = @_;
my(undef,$new_sessionname,$new_image_id,$new_filename,$new_super_id) = @_;
my(undef,undef,undef,$select_page) = @_ if($type =~ /Get-index/);
my($index_line,$maxview_index,$guide1);
my(@renewline,$file,$allpaint_handler,$top1,$renewline_max,$maxsave_time,$i);

# �t�@�C����`
if($type =~ /Buffer/){ $file = "${main::int_dir}_sinnchaku/paint_buffer.log"; }
elsif($type =~ /Justy/){ $file = "${main::int_dir}_sinnchaku/allpaint.log"; }
else{ return(); }

# �ꎞ�摜��ۑ�����ő厞�ԁi�o�b�t�@�p�j [ �b�Ŏw�� ]
$maxsave_time = 7*24*60*60;
#if($main::alocal_mode){ $maxsave_time = 60*5; }

# �L�^����ő�s��(�V���ꗗ)
$renewline_max = 500;

# �\������ő�s��
$maxview_index = 10;

# �t�@�C�����J��
open($allpaint_handler,"<$file");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($allpaint_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp($top1 = <$allpaint_handler>);
my($tkey) = split(/<>/,$top1);

	# �g�b�v�f�[�^�̕⊮
	if($tkey eq ""){ $tkey = 1; }

	# �t�@�C����W�J
	while(<$allpaint_handler>){

		# ���E���h�J�E���^
		$i++;
	
		# ���̍s�𕪉�
		chomp;
		my($key2,$session2,$filename2,$image_id2,$time2,$date2,$addr2,$host2,$agent2,$cnumber2,$super_id2) = split(/<>/);

			# �t�@�C�����𕪉�
			my($realmoto2,$postnumber2,$resnumber2,$image_tail2) = split(/-/,$filename2);

			# ���C���f�b�N�X�擾�p�̏���
			if($type =~ /Get-index/){

				# �y�[�W�߂���Ŏ��̏�����
				if($i > $maxview_index * $select_page){ next; }
				if($i <= $maxview_index * ($select_page-1)){ next; }

				# �n�b�V�����擾
				my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,$main::server_domain,$realmoto2,$postnumber2,$resnumber2);

					# �\�����e���`
					if($image{'image_ok'}){

							# �T���l�C���̕\��
							if($main::admin_mode){
								$index_line .= qq(<a href="${main::script}?mode=pallet-viewer-$realmoto2-$postnumber2-$resnumber2">);
							}
							else{
								$index_line .= qq(<a href="${main::main_url}pallet-viewer-$realmoto2-$postnumber2-$resnumber2.html">);
							}

						$index_line .= qq(<img src="$image{'samnale_url'}" class="noborder" style="width:$image{'samnale_width'}px;height:$image{'samnale_height'}px;"$main::xclose>);
						$index_line .= qq(</a>);

							# ���e��̃��X�̕\��
							if(!$image{'main_type'}){
									if($main::admin_mode){
										$index_line .= qq( <a href="$realmoto2.cgi?mode=view&amp;no=$postnumber2#S$resnumber2">���e</a>\n);
									}
									else{
										$index_line .= qq( <a href="/_$realmoto2/$postnumber2.html-$resnumber2">���e</a>\n);
									}
							}
						$index_line .= qq( $date2);
						$index_line .= qq(<br$main::xclose><br$main::xclose>\n);
					}
			}

			# ���t�@�C���X�V�p�̏���
			if($type =~ /Renew/){

					# �Ǐ���
					my($plustype_delete);

					# �d�������X�[�p�[ID���폜����
					if($super_id2 eq $new_super_id){ $super_id2 = ""; }

					# �Z�b�V����ID�������̏ꍇ�A���Ƃ��烍�O�t�@�C���������폜����Ȃ��悤�ɂ���
					if($key2 =~ /Not-delete-logfile/){ $plustype_delete .= qq( Not-delete-logfile); }
					elsif($session2 eq $new_sessionname){ $key2 .= " Not-delete-logfile"; }

					# �ő�s���ɒB�����ꍇ�A�Â��o�b�t�@�t�@�C�����폜���Ď��̏�����
					if($type =~ /Justy/ && $i + 1 > $renewline_max){
						next;
					}

					# ��莞�ԍX�V���Ȃ��ꍇ�A�Â��o�b�t�@�t�@�C�����폜���Ď��̏�����
					if($type =~ /Buffer/ && $main::time >= $time2+$maxsave_time){
							Mebius::Paint::Image("Delete-buffer$plustype_delete",$session2,$image_id2);
							if($super_id2){ Mebius::Paint::Super_id("Delete-file",$super_id2); }
							next;
					}


				# �ǉ�����s
				push(@renewline,"$key2<>$session2<>$filename2<>$image_id2<>$time2<>$date2<>$addr2<>$host2<>$agent2<>$cnumber2<>$super_id2<>\n");

			}
	}

# �t�@�C�������
close($allpaint_handler);

	# ���C���f�b�N�X�擾�̌㏈��
	if($type =~ /Get-index/){
		$guide1 = qq(<a href="./pallet.html">���V�����G��`��</a>);
		return($index_line,$guide1);
	}

	# ���t�@�C���X�V����ꍇ
	elsif($type =~ /Renew/){

		# �V�����s��ǉ�
		if($type =~ /New/){
			unshift(@renewline,"1<>$new_sessionname<>$new_filename<>$new_image_id<>$main::time<>$main::date<>$main::addr<>$main::host<>$main::agent<>$main::cnumber<>$new_super_id<>\n");
		}

		# �g�b�v�f�[�^��ǉ�
		unshift(@renewline,"$tkey<>\n");

		# �t�@�C���X�V
		Mebius::Fileout("",$file,@renewline);
	}

}



1;
