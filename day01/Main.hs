import Data.Bifunctor (Bifunctor (bimap, second))
import Data.IntMap.Strict qualified as IM
import Data.List (elemIndex, sort)
import Data.Maybe (fromJust)

parseLine :: String -> (Int, Int)
parseLine ln = bimap readTrans readTrans (take i, drop $ i + 3)
  where
    i = fromJust $ ' ' `elemIndex` ln
    readTrans = read . ($ ln)

part1 :: [(Int, Int)] -> Int
part1 = sum . map abs . uncurry (zipWith (-)) . bimap sort sort . unzip

part2 :: [(Int, Int)] -> Int
part2 = uncurry score . second count . unzip
  where
    count r = foldl' (\counts x -> IM.insertWith (+) x 1 counts) IM.empty r
    score l counts = sum . (zipWith (*) <*> map getCount) $ l
      where
        getCount x = IM.findWithDefault 0 x counts

main :: IO ()
main = interact $ unlines . map show . zipWith ($) [part1, part2] . repeat . map parseLine . lines
