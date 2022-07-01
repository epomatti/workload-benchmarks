using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace pets.Migrations
{
    public partial class InitialCreate2 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "SimpleParents",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    String1 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    String2 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    String3 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Number1 = table.Column<int>(type: "int", nullable: false),
                    Number2 = table.Column<int>(type: "int", nullable: false),
                    Number3 = table.Column<int>(type: "int", nullable: false),
                    DateTime1 = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DateTime2 = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DateTime3 = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SimpleParents", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "SimpleChildren1",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    String1 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    String2 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Number1 = table.Column<int>(type: "int", nullable: false),
                    Number2 = table.Column<int>(type: "int", nullable: false),
                    DateTime1 = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DateTime2 = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ParentId = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SimpleChildren1", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SimpleChildren1_SimpleParents_ParentId",
                        column: x => x.ParentId,
                        principalTable: "SimpleParents",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SimpleChildren2",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    String1 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    String2 = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Number1 = table.Column<int>(type: "int", nullable: false),
                    Number2 = table.Column<int>(type: "int", nullable: false),
                    DateTime1 = table.Column<DateTime>(type: "datetime2", nullable: false),
                    DateTime2 = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ParentId = table.Column<long>(type: "bigint", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SimpleChildren2", x => x.Id);
                    table.ForeignKey(
                        name: "FK_SimpleChildren2_SimpleParents_ParentId",
                        column: x => x.ParentId,
                        principalTable: "SimpleParents",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateIndex(
                name: "IX_SimpleChildren1_ParentId",
                table: "SimpleChildren1",
                column: "ParentId");

            migrationBuilder.CreateIndex(
                name: "IX_SimpleChildren2_ParentId",
                table: "SimpleChildren2",
                column: "ParentId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "SimpleChildren1");

            migrationBuilder.DropTable(
                name: "SimpleChildren2");

            migrationBuilder.DropTable(
                name: "SimpleParents");
        }
    }
}
