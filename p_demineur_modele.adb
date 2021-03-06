---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
--************************************ COPYRIGHT 2020 - Artaud Alexandre ************************************--
--******************** Toute copie de ce fichier doit se faire en citant son auteur *************************--
--************************************ Date de création : 12/06/2020 ****************************************--
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------



with text_io; use text_io;
with p_esiut;use p_esiut;

with Ada.Numerics.Discrete_Random;

package body p_demineur_modele is

---------------------------------------------------------------------------------------------------------------------------------------------
    -- Cette procédure DévoileCase permet de changer l'attribrut Etat du vecteur G(L,C) en passant de l'Etat couverte à déccouverte 
    -- (En prenant en compte le fait que si elle est découverte, cela ne change rien)
    procedure DevoileCase ( G : in out TV_Grille; L: in positive; C : in positive) is
    --{G, L, C} => {La case en position (L,C) dans la grille G est dévoilée et éventuellement ses voisines}
    begin
        if G(L, C).Etat = couverte then
            if NombreMineAutour(G, L, C) = 0 
            then G(L, C).Etat := decouverte;
            declare
                L1, L2, C1, C2 : natural :=0; --Variables pour les lignes et colonnes à check
            begin
                --Check ligne
                if L = 1 -- Check si le curseur est sur la premiere ligne (qui veut dire qu'on ne peut pas chercher la ligne au dessus car elle n'existe pas)
                then L1 := 1; L2 := 0; -- On regarde donc la ligne du dessous
                elsif L = G'last (1) -- Check si le curseur est sur la dernière ligne (qui veut dire qu'on ne peut pas chercher la ligne en dessous car elle n'existe pas)
                then L1 := 0; L2 := 1;  -- On regarde donc la ligne au dessus
                else L1 := 1; L2 := 1; -- Dernière possibilité plausible; le curseur n'est ni sur la première ni sur la dernière ligne et donc on check au dessus et en dessous
                end if;
                -- Check colonne
                if C = 1 -- Check si le curseur est sur la premiere colonne (qui veut dire qu'on ne peut pas chercher la colonne de gauche car elle n'existe pas)
                then C1 := 1; C2 := 0; -- On regarde donc la colonne de droite
                elsif C = G'last (2) -- Check si le curseur est sur la dernière colonne (qui veut dire qu'on ne peut pas chercher la colonne de droite car elle n'existe pas)
                then C1 := 0; C2 := 1; -- On regarde donc la colonne de gauche
                else C1 := 1; C2 := 1; -- Dernière possibilité plausible; le curseur n'est ni sur la première ni sur la dernière colonne et donc on check à droite et à gauche
                end if;
                -- Grace à la partie du dessus, on trouve i et j qui vont nous permettre de dévoiler les cases en les reinjectant
                for i in L-L2..L+L1 loop
                    for j in C-C2..C+C1 loop
                        DevoileCase(G, I, J);
                    end loop;
                end loop;
            end;
        else
            G(L, C).Etat := decouverte;
            end if;
        end if;
    end DevoileCase;

    ---------------------------------------------------------------------------------------------------------------------------------------------

    function NombreMineAutour(G : in TV_Grille; L : in positive; C : in positive) return natural is
        -- --{G, L, C} =>{résultat = nombre de mines présentes dans les cases adjacents à la case (L,C) de G}
        -- On reprend la meme base de fonctione que pour DevoileCase mais en modifiant la fin pour pouvoir return un natural qui nous permettra de vérifier une condition dans p_vue
        L1, L2, C1, C2 : natural :=0;
        k : natural := 0;
    begin
        --Check ligne
        if L = 1 -- Check si le curseur est sur la premiere ligne (qui veut dire qu'on ne peut pas chercher la ligne au dessus car elle n'existe pas)
        then L1 := 1; L2 := 0; -- On regarde donc la ligne du dessous
        elsif L = G'last(1) -- Check si le curseur est sur la dernière ligne (qui veut dire qu'on ne peut pas chercher la ligne en dessous car elle n'existe pas)
        then L1 := 0; L2 := 1;  -- On regarde donc la ligne au dessus
        else L1 := 1; L2 := 1; -- Dernière possibilité plausible; le curseur n'est ni sur la première ni sur la dernière ligne et donc on check au dessus et en dessous
        end if;
        -- Check colonne
        if C = 1 -- Check si le curseur est sur la premiere colonne (qui veut dire qu'on ne peut pas chercher la colonne de gauche car elle n'existe pas)
        then C1 := 1; C2 := 0; -- On regarde donc la colonne de droite
        elsif C = G'last(2) -- Check si le curseur est sur la dernière colonne (qui veut dire qu'on ne peut pas chercher la colonne de droite car elle n'existe pas)
        then C1 := 0; C2 := 1; -- On regarde donc la colonne de gauche
        else C1 := 1; C2 := 1; -- Dernière possibilité plausible; le curseur n'est ni sur la première ni sur la dernière colonne et donc on check à droite et à gauche
        end if;
        for i in L-L2..L+L1 loop
            for j in C-C2..C+C1 loop    
                if G(i, j).Occupee 
                then k := k + 1;
                end if;
            end loop;
        end loop;
        return k;
    end NombreMineAutour;

    ---------------------------------------------------------------------------------------------------------------------------------------------

	procedure MarqueCase (G : in out TV_Grille; L : in positive; C : in positive; isMarquee : out boolean) is
	--{G, L, C, isMarque} => { La case en position (L,C) dans la grille G est marquée si elle était couverte / couverte si elle était marquée et isMarque prend true si la valuer a ete changer}
	begin
		if G(L, C).Etat = Couverte then -- Si couverte -> Marquée
			G(L, C).Etat := Marquee;
		else
			G(L, C).Etat := Couverte; --> Sinon devient couverte
		end if;
        isMarquee := (G(L, C).Etat = Marquee);
	end MarqueCase;
 
    ---------------------------------------------------------------------------------------------------------------------------------------------

	function VictoireJoueur (G : in TV_Grille) return Boolean is
	--{G} => { Vrai si toutes les cases libres de la grille G sont dévoilées et non occupee}
	    victoire : boolean := true;
	begin
		for ligne in G'Range(1) loop
			for colonne in G'Range(2) loop
			    if  G(ligne, colonne).Etat = couverte and not G(ligne,colonne).Occupee then --si case est couverte et non occupée 
                    victoire := false; --perdu !!
			    end if;
			end loop;
		end loop;
	    return victoire;
	end VictoireJoueur;

    function DefaiteJoueur (G: in TV_Grille; L, C : in Positive) return Boolean is 
    --{G, L, C}=>{ Vrai si la case est occupée }
    begin
        return G(L, C).Occupee;
    end DefaiteJoueur;

    ---------------------------------------------------------------------------------------------------------------------------------------------

	procedure InitialiseGrille (G : out TV_Grille ; NbMines : in natural) is
        --{NbMines < G'length(1)*G'length(2)} => {NbMines ont été placées au hasard dans G ; toutes les cases sont couvertes}
	 
        subtype CaseRX is  positive range 1..G'length(1); -- Défini un subtype CaseR positif entre 1 et le nombre de case max
        package randomizerX is new Ada.Numerics.Discrete_Random(CaseRX); use randomizerX; --Implémentation du randomizer sur CaseR

        subtype CaseRY is  positive range 1..G'length(2); -- Défini un subtype CaseR positif entre 1 et le nombre de case max
        package randomizerY is new Ada.Numerics.Discrete_Random(CaseRY); use randomizerY; --Implémentation du randomizer sur CaseR

		genX : randomizerX.Generator;
        genY : randomizerY.Generator;
		CaseX : CaseRX; 
		CaseY : CaseRY; 
		x, y : Positive;
        counter : integer := 0;
	begin
		Reset(genX);
        Reset(genY);
		for ligne in G'range(1) loop -- range(1) = première dim
			for colonne in G'range(2) loop -- range(2) = deuxieme dim
				G(ligne, colonne).Etat := couverte;
				G(ligne, colonne).Occupee := false;
			end loop;
		end loop;
		
		while counter < NbMines loop
			CaseX := random(genX); -- Générateur de nombre aléatoire dans le domaine défini au préalable
            CaseY := random(genY);
			x := CaseX;
			y := CaseY;
            if x <= G'Length(1) and y <= G'Length(2) then
                if not G(x, y).Occupee then -- Cela permet de remplir les cases innocupées et les occuper.
				    G(x, y).Occupee := true;
                    counter := counter+1;
			    end if;
            end if;
		end loop;
	end InitialiseGrille;

    ---------------------------------------------------------------------------------------------------------------------------------------------

    procedure Restart (G : in out TV_Grille) is
    --{G} => { Remet l'etat des cases a leur etats original }
        C : TR_Case;
    begin
        for ligne in G'Range(1) loop
            for colonne in G'Range(2) loop
                C := G(ligne, colonne);
                C.Etat := Couverte;
                G(ligne, colonne) := C;
            end loop;
        end loop;
    end Restart;

    ---------------------------------------------------------------------------------------------------------------------------------------------

    function VerificationMarquage(G : in TV_Grille;  NombreBombe : in Positive) return boolean is
    --{G, NombreBombe} => { Retourne true si on a le bon nombre de case marquée et que les autres case ne sont pas marqué }
        NBombe, NCase : integer;
    begin
        GetMarque(G, NBombe, NCase);
        return NBombe = NombreBombe and NCase = 0;
    end VerificationMarquage;
    
    procedure GetMarque(G : in TV_Grille; NBombe, NCase : out integer) is
    --{G} => { Retourne NBombe le nombre de bombe marque et NCase le nombre de case marqué qui ne sont pas des bombes }
        C : TR_Case;
    begin
        NBombe := 0;
        NCase := 0;
        for ligne in G'Range(1) loop
            for colonne in G'Range(2) loop
                C := G(ligne, colonne);
                if C.Etat = Marquee and C.Occupee then
                    NBombe := NBombe+1;
                elsif C.Etat = Marquee and not C.Occupee then
                    NCase := NCase+1;
                end if;
            end loop;
        end loop;
        ecrire("NBombe : "); ecrire_ligne(NBombe);
        ecrire("NCase : "); ecrire_ligne(NCase);
    end GetMarque;

end p_demineur_modele;