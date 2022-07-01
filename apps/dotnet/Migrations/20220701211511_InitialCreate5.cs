using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace pets.Migrations
{
    public partial class InitialCreate5 : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DateTimeControl1",
                table: "SimpleParents",
                type: "datetime2",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.AddColumn<string>(
                name: "InnerString1",
                table: "SimpleParents",
                type: "nvarchar(max)",
                nullable: true);

            migrationBuilder.AddColumn<long>(
                name: "Sum1",
                table: "SimpleParents",
                type: "bigint",
                nullable: false,
                defaultValue: 0L);
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DateTimeControl1",
                table: "SimpleParents");

            migrationBuilder.DropColumn(
                name: "InnerString1",
                table: "SimpleParents");

            migrationBuilder.DropColumn(
                name: "Sum1",
                table: "SimpleParents");
        }
    }
}
