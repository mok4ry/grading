# Take a text file (meant to be source code) and turn it into a PDF.
#
# Usage:
#   $ ruby file-to-pdf.rb [ file1, file2, ... fileN ]
#
#
# Matt Mokary (mxm6060@rit.edu)

def main
    ARGV.each do |arg|
        make_pdf arg
    end
end

def make_pdf filename
    without_extension = get_title(filename)
    tex =  "\\documentclass[a4paper,12pt]{article}\n"
    tex += "\\usepackage[margin=0.75in]{geometry}\n"
    tex += "\\usepackage{graphicx}\n"
    tex += "\\usepackage{setspace}\n"
    tex += "\\newcommand{\\tab}{\\hspace*{3em}}\n"
    tex += "\\title{#{without_extension}}\n"
    tex += "\\begin{document}\n"
    tex += "\\maketitle\n"
    tex += "\\ttfamily\n"
    tex += "\\begin{verbatim}\n"
    File.open( filename, "r" ).each do |line|
        line.gsub! /\t/, "    "
        tex += line
    end
    tex += "\n\\end{verbatim}\n"
    tex += "\\end{document}"

    out_filename = without_extension + ".tex"
    write_to_file out_filename, tex
    compile_to_pdf out_filename
    clean_up without_extension
end

def clean_up file
    `rm #{file + ".aux"}`
    `rm #{file + ".log"}`
    `rm #{file + ".tex"}`
end

def compile_to_pdf file
    `pdflatex #{file}`
end

def write_to_file out_filename, contents
    outfile = File.new( out_filename, "w" )
    outfile.write( contents )
    outfile.close
end

def get_title filename
    filename[0...filename.index(/\./)]
end

if __FILE__ == $0
    main
end
