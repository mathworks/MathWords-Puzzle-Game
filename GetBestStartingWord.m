mathWords = readtable( "MathWordsDictionary.xlsx", TextType="string" );

idx = ~contains( mathWords.Hint, "*not used*" );
mathWords = mathWords.Function(idx);

% allWords = readtable( "MathWordsDictionary.xlsx", TextType="string", Sheet="AllWords" );

letters = char( mathWords ); 
letters = categorical( string( letters(:) ) );
[counts,letters] = histcounts( letters ); 
[counts,j] = sort( counts, 2, "descend" );
letters = string( letters(j) );
letters(1:5)

n = numel( mathWords );
C = repmat( counts, n, 1 );
scores = zeros( n, 1 );
for k = 1:strlength(mathWords(1))
    [j,~] = find( (extract( mathWords, k ) == letters)' );
    scores = scores + counts(j)';
end

[scores,i] = sort( scores, 1, "descend" );
bestWords = mathWords(i);

idx = ~contains(mathWords,"P") & contains(mathWords,"A") & ...
    ~contains(mathWords,"R") & contains(mathWords,"S") & ~contains(mathWords,"E");
mathWords(idx)