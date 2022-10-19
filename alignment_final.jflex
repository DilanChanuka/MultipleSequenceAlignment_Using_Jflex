import java.util.Collections; 
import java.util.*;
import java.io.*;
import java.util.Arrays; 
import java.util.regex.Matcher;
import java.util.regex.Pattern;

%%

%class AlignmentTool
%standalone
%line
%column
%state READ
%state LINE_TERMINATE

Start = [\>]
LineEnd = \r|\n|\r\n
FastaSequence = [A+C+U+G]+|[A+C+T+G]+|[A+R+N+D+C+Q+E+G+H+I+L+K+M+F+P+S+T+W+Y+V]+

%{
    static String str_tmp = "";
    static int seq_len = 0;
    static int min_seq_len = 0;
    static List<Integer> seq_len_list=new ArrayList<Integer>();
    static int sequenceCount = 0;
    static String[] regX;
    static String finalRegX = "";
    static List<String> seq_list=new ArrayList<String>();

    public static class Location {
        int i, j, len;
        Location(int i, int j, int len) {
            this.i = i;
            this.j = j;
            this.len = len;
        }
    }

    public static Location findCommonString(String s1,String s2){
        int n = s1.length();
        int m = s2.length();
        Location ans = new Location(0, 0, 0);
        int[] a;
        int b[] = new int[m];
        int indexes[] = new int[2];
        for(int i = 0;i<n;i++){
            a = new int[m];
            for(int j = 0;j<m;j++){
                if(s1.charAt(i)==s2.charAt(j)){
                    if(i==0 || j==0 )a[j] = 1;
                    else{
                        a[j] = b[j-1] + 1;
                    }
                    if(a[j]>ans.len) {
                        ans.len = a[j];
                        ans.i=(i+1) - ans.len;
                        ans.j=(j+1) - ans.len;
                    }
                }
            }
            b = a;
        }
        return ans;
    }

    public static void printAlignment(){
        Pattern pattern = Pattern.compile(finalRegX);
        List<Integer> start_index_list = new ArrayList<Integer>();
        List<String> final_sequence_list = new ArrayList<String>();
        boolean equalChars = false;
        char letter = ' ';
        StringBuilder sb0 = new StringBuilder();
        int chunkSize = 100;
        int indexStart = 0;
        int indexEnd = chunkSize - 1;
        int exactMatchCount = 0;

        for(int i = 0; i<sequenceCount; i++){
            Matcher m = pattern.matcher(seq_list.get(i));
            while (m.find()) {
                start_index_list.add(m.start());
                System.out.println("Pattern found from " + m.start() + " to " + (m.end() - 1));
            }
            System.out.println(); 
        } 
        if(start_index_list.size() == sequenceCount) {
            int maxIndex = Collections.max(start_index_list); 
            int maxPadding = maxIndex - Collections.min(start_index_list);
            int paddingCount_L = 0;
            int paddingCount_R = 0;
            for(int i = 0; i<sequenceCount; i++){ 
                StringBuilder sb1 = new StringBuilder();
                paddingCount_L = maxIndex - start_index_list.get(i);
                paddingCount_R = maxPadding - paddingCount_L;
            
                if(paddingCount_L > 0) {
                    for (int k = 0; k < paddingCount_L; k++) 
                        sb1.append('_');
                    sb1.append(seq_list.get(i));
                } else {
                    sb1.append(seq_list.get(i));
                }
                if(paddingCount_R > 0) {
                    for (int k = 0; k < paddingCount_R; k++) 
                        sb1.append('_');
                }
                final_sequence_list.add(sb1.toString());             
            }
        } else {
            System.out.println("Index detection error !");
        }
        if(final_sequence_list.size() > 0){
            for(int i = 0; i<final_sequence_list.get(0).length(); i++) { 
                for(int j = 0; j<final_sequence_list.size(); j++) {
                    if((final_sequence_list.get(j).length() - 1) < i) {
                        equalChars = false;
                        continue;
                    }
                    if(j==0) {
                        letter = final_sequence_list.get(j).charAt(i);
                        equalChars = true;
                    } else {
                        if(letter != final_sequence_list.get(j).charAt(i)) {
                            equalChars = false;
                        }
                    }
                }
                if(equalChars) {
                    sb0.append('*');
                    exactMatchCount++;
                } else {
                    sb0.append('_');
                }
            }
            final_sequence_list.add(sb0.toString());
        }
        for(int i = 0; i < Math.ceil(final_sequence_list.get(0).length() / chunkSize) + 1; i++) {
            for(int j = 0; j<final_sequence_list.size(); j++) { 
                if(indexEnd > (final_sequence_list.get(j).length() - 1)){
                    indexEnd = final_sequence_list.get(j).length() - 1;
                }
                if(indexEnd <= (final_sequence_list.get(j).length() - 1) 
                    && indexStart <= (final_sequence_list.get(j).length() - 1)
                    && indexStart != indexEnd && indexEnd > indexStart){
                    System.out.println(final_sequence_list.get(j).substring(indexStart, indexEnd));
                }
            }
            System.out.println();
            indexStart = indexEnd + 1;
            indexEnd += chunkSize + 1;
        }
        System.out.println("Exact Matches: " + exactMatchCount);
    }

    public static void startAlignment(){
        min_seq_len = Collections.min(seq_len_list); 
        regX = new String[sequenceCount-1];
        Location location;
        for(int i = 0; i<sequenceCount-1; i++){
            location = findCommonString(seq_list.get(i),seq_list.get(i+1));
            regX[i] = seq_list.get(i).substring(location.i, location.i + location.len);
        }
        System.out.print("RegX Array: ");
        System.out.println(Arrays.deepToString(regX));
        finalRegX = findCommonRegX();
        System.out.print("Final RegX: ");
        System.out.println(finalRegX + "\n");
    }

    public static String findCommonRegX() {
        String tmp_str = "";
        Location location;
        for(int i = 0; i<regX.length-1; i++){
            if (regX[i].length() != 0 && regX[i+1].length() != 0 && i == 0) {
                location = findCommonString(regX[i],regX[i+1]);
                tmp_str = regX[i].substring(location.i, location.i + location.len);
            } else if (tmp_str.length() != 0 && regX[i+1].length() != 0) {
                location = findCommonString(tmp_str,regX[i+1]);
                tmp_str = tmp_str.substring(location.i, location.i + location.len);
            }
        }
        return tmp_str;
    }    

%}

%%

<YYINITIAL> {    
    {Start}   {  
        int lineNo = yyline+1;
        sequenceCount++;
        System.out.println("FastaFile Line No: "+lineNo); 
        System.out.println("Sequence Count: "+sequenceCount);
        System.out.println("Sequence Details:");
        yybegin(LINE_TERMINATE);   
    }
}

<LINE_TERMINATE> {    
    {LineEnd}    {    
        yybegin(READ);
    }
}

<READ> {
        
    {FastaSequence} {   
        str_tmp = str_tmp.concat(yytext().trim());  
        seq_len += yytext().trim().length();
    }

    {LineEnd} {
        System.out.println("\nSequence Length: "+seq_len+"\n");
        seq_list.add(str_tmp);   
        seq_len_list.add(seq_len);
        str_tmp = "";
        seq_len = 0;
        yybegin(YYINITIAL);
    }
    
    \n                  {/* Do Nothing */}
    .                   {/* Do Nothing */}
}

<<EOF>> {
    startAlignment();
    printAlignment();
    System.exit(0);
}
