SET SERVEROUTPUT ON
CREATE TABLE recipes (
    recipe_id   NUMBER PRIMARY KEY,
    title       VARCHAR2(100),
    description VARCHAR2(500),
    instructions CLOB
);
ALTER TABLE recipes ADD created_date DATE;

CREATE TABLE ingredients (
    ingredient_id NUMBER PRIMARY KEY,
    name          VARCHAR2(100)
);

CREATE TABLE recipe_ingredients (
    recipe_id     NUMBER,
    ingredient_id NUMBER,
    quantity      VARCHAR2(50),
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes (recipe_id),
    FOREIGN KEY (ingredient_id) REFERENCES ingredients (ingredient_id)
);

CREATE OR REPLACE PROCEDURE add_recipe(
    p_recipe_id     IN NUMBER,
    p_title         IN VARCHAR2,
    p_description   IN VARCHAR2,
    p_instructions  IN CLOB
)
IS
BEGIN
    INSERT INTO recipes (recipe_id, title, description, instructions)
    VALUES (p_recipe_id, p_title, p_description, p_instructions);
END;


CREATE OR REPLACE PROCEDURE add_ingredient_to_recipe(
    p_recipe_id     IN NUMBER,
    p_ingredient_id IN NUMBER,
    p_quantity      IN VARCHAR2
)
IS
BEGIN
    INSERT INTO recipe_ingredients (recipe_id, ingredient_id, quantity)
    VALUES (p_recipe_id, p_ingredient_id, p_quantity);
END;


CREATE OR REPLACE PROCEDURE get_recipe_ingredients(
    p_recipe_id IN NUMBER
)
IS
BEGIN
    FOR ingredient_rec IN (
        SELECT i.name, ri.quantity
        FROM ingredients i
        INNER JOIN recipe_ingredients ri ON i.ingredient_id = ri.ingredient_id
        WHERE ri.recipe_id = p_recipe_id
    )
    LOOP
        
        DBMS_OUTPUT.PUT_LINE('Ingredient Name: ' || ingredient_rec.name);
        DBMS_OUTPUT.PUT_LINE('Quantity: ' || ingredient_rec.quantity);
        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    END LOOP;

    IF SQL%NOTFOUND THEN
        DBMS_OUTPUT.PUT_LINE('No ingredients found for the recipe.');
    END IF;
END;

CREATE OR REPLACE PROCEDURE get_all_recipes
IS
    CURSOR recipe_cursor IS
        SELECT *
        FROM recipes;
        
    recipe_row recipes%ROWTYPE;
BEGIN
    OPEN recipe_cursor;
    
    LOOP
        FETCH recipe_cursor INTO recipe_row;
        EXIT WHEN recipe_cursor%NOTFOUND;
        
        -- Process the recipe data
        -- You can print the recipe details or perform any other operations here
        DBMS_OUTPUT.PUT_LINE('Recipe ID: ' || recipe_row.recipe_id);
        DBMS_OUTPUT.PUT_LINE('Title: ' || recipe_row.title);
        DBMS_OUTPUT.PUT_LINE('Description: ' || recipe_row.description);
        DBMS_OUTPUT.PUT_LINE('Instructions: ' || recipe_row.instructions);
        DBMS_OUTPUT.PUT_LINE('-----------------------------------');
    END LOOP;
    
    CLOSE recipe_cursor;
END;
CREATE OR REPLACE FUNCTION get_total_ingredients(p_recipe_id IN NUMBER)
    RETURN NUMBER
IS
    total_ingredients NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO total_ingredients
    FROM recipe_ingredients
    WHERE recipe_id = p_recipe_id;
    
    RETURN total_ingredients;
END;
CREATE OR REPLACE TRIGGER insert_timestamp
BEFORE INSERT ON recipes
FOR EACH ROW
BEGIN
    :NEW.created_date := SYSDATE;
END;
SET SERVEROUTPUT ON
BEGIN
    add_recipe(3, 'Spaghetti Bolognese', 'Classic Italian pasta dish.', '1. Boil the spaghetti...\n2. Heat oil in a pan...\n3. Add minced meat and cook...');
END;
BEGIN
        add_ingredient_to_recipe(2,1,200);
END;
BEGIN 
      get_all_recipes;
END;
BEGIN
        get_recipe_ingredients(2);
END;
DECLARE
c NUMBER;
BEGIN
    c:=get_total_ingredients(1);
    dbms_output.put_line('Total Ingredients :' ||c);
END;
SELECT * from ingredients
