#!/usr/bin/env perl

use 5.10.1;

use strict;
use warnings;
use utf8;

use Data::Dumper;
use DateTime;
use DateTime::Format::RFC3339;
use DateTime::Format::Mail;
use Text::Markdown 'markdown';
use File::Basename;
use Template;

sub parse_post_file {
    use constant {
        METADATA => 0,
        CONTENT => 1
    };
    my $parse_state = METADATA;

    my %post = ();
    my $content = "";

    my ($file_name) = @_;
    open(my $fh, $file_name);
    binmode($fh, ':utf8');
    while (<$fh>) {
        if ($parse_state == METADATA) {
            if (my ($key, $value) = $_ =~ m/^\s*([a-zA-Z0-9_]+)\s*:\s*(.*)\s*$/) {
                $post{lc $key} = $value;
            } else {
                $parse_state = CONTENT;
                $content = $content . $_;
            }
        } else {
            $content = $content . $_;
        }
    }
    close($fh);

    $post{content} = $content;

    return \%post;
}

sub get_all_post_files {
    my ($posts_directory) = @_;
    my @posts = ();

    opendir(my $dh, $posts_directory) or die $!;
    while (my $file = readdir($dh)) {
        if ($file =~ m/.*\.md/) {
            push @posts, "$posts_directory/$file";
        }
    }
    closedir($dh);

    return \@posts;
}

sub prepare_posts {
    my ($post_file_names) = @_;
    my $rfc3339 = DateTime::Format::RFC3339->new();
    my @posts = ();

    foreach (@$post_file_names) {
        my $page_name = basename $_, (".md");
        my $post = parse_post_file($_);
        my $date = DateTime::Format::Mail->parse_datetime($post->{date});
        $date->set_formatter($rfc3339);

        $post->{content} = markdown($post->{content});
        $post->{date} = $date;
        $post->{page_name} = $page_name;

        push @posts, $post;
    }

    @posts = sort {
        DateTime->compare($b->{date}, $a->{date});
    } @posts;

    return \@posts;
}

sub settings_from_args {
    my ($settings) = @_;
    foreach (@ARGV) {
        if ($_ eq '--comments-enabled') {
            $settings->{comments_enabled} = 1;
        } else {
            die "$_ is unknown option\n";
        }
    }
}

sub main {
    my $settings = {
        comments_enabled => 0
    };
    settings_from_args($settings);

    print Dumper($settings), "\n";

    my $posts = prepare_posts(get_all_post_files("./posts/"));
    my $template = Template->new({ RELATIVE => 1,
                                   INCLUDE_PATH => "./templates",
                                   ENCODING => 'utf8' });

    print "[INFO] index.html ... ";
    $template->process("./templates/index.tt",
                       { posts => $posts },
                       "./html/index.html",
                       { binmode => ':utf8' }) || die $template->error();
    print "DONE\n";

    foreach(@$posts) {
        my $page_name = $_->{page_name};
        print "[INFO] $page_name.html ... ";
        $template->process("./templates/post.tt",
                           { post => $_,
                             settings => $settings},
                           "./html/$page_name.html",
                           { binmode => ':utf8' }) || die $template->error();
        print "DONE\n";
    }

    print "[INFO] sitemap.xml ... ";
    $template->process("./templates/sitemap.tt",
                       { baseurl => 'http://rexim.me/',
                         posts => $posts },
                       "./html/sitemap.xml",
                       { binmode => ':utf8' }) || die $template->error();
    print "DONE\n";

    print "[INFO] rss.xml ... ";
    $template->process("./templates/rss.tt",
                       { baseurl => 'http://rexim.me/',
                         posts => $posts },
                       "./html/rss.xml",
                       { binmode => ':utf8' }) || die $template->error();

    print "DONE\n";
}

main();

1;
